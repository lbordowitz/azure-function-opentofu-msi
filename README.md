# Demo Setup for [OpenTofu Issue #3010](https://github.com/opentofu/opentofu/issues/3010):

This repository contains a minimal setup to reproduce the bug reported as [OpenTofu Issue #3010](https://github.com/opentofu/opentofu/issues/3010):

# Title
OpenTofu does not accept authentication from Azure CLI via Managed Identity when reading remote state using `terraform_remote_state`.


# OpenTofu Version

```
$ tofu --version
OpenTofu v1.10.2
on linux_amd64
+ provider registry.opentofu.org/hashicorp/azurerm v4.34.0
+ provider registry.opentofu.org/hashicorp/null v3.2.4
```


# OpenTofu Configuration Files
See [`azure-function-opentofu-msi/container-image/tf-demo/main.tf`](https://github.com/ulkeba/azure-function-opentofu-msi/blob/main/container-image/tf-demo/main.tf) in [`azure-function-opentofu-msi/container-image/tf-demo/deploy.sh`](https://github.com/ulkeba/azure-function-opentofu-msi/blob/main/container-image/tf-demo/deploy.sh) in [`ulkeba/azure-function-opentofu-msi`](https://github.com/ulkeba/azure-function-opentofu-msi).

(Usage of `data "terraform_remote_state" "shared" {...}` on Azure Backend, when authenticating with Managed Identity.)

# Debug Output
See [`azure-function-opentofu-msi/log/terraform-debug-clean.log` in `ulkeba/azure-function-opentofu-msi`](https://github.com/ulkeba/azure-function-opentofu-msi/blob/main/log/terraform-debug-clean.log).

# Expected Behavior

When authenticating from an Azure Function (or any other resource) via Azure CLI using a managed identity by invoking
```
az login --identity [--client-id ...]
```
this authentication should be accepted to retrieve data from a remote state.

# Actual Behavior

Upfront authentication via `az login --identity` is rejected:
```
Error: Error building ARM Config: Authenticating using the Azure CLI is only supported as a User (not a Service Principal).

To authenticate to Azure using a Service Principal, you can use the separate 'Authenticate using a Service Principal'
auth method - instructions for which can be found here: https://registry.opentofu.org/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret

Alternatively you can authenticate using the Azure CLI by using a User Account.


Error: data.terraform_remote_state.shared: Unable to read remote state
```

(Note: This problem only occurs when reading remote state using `terraform_remote_state`; it is _not_ a problem when managing Azure resources using a local backend.)


# Steps to Reproduce

1. Clone the repository [ulkeba/azure-function-opentofu-msi](https://github.com/ulkeba/azure-function-opentofu-msi).

1. Open the cloned repository in VSCode and start the defined DevContainer (this will run script `.devcontainer/install-tools.sh` to install Azure CLI and OpenTofu in the DevContainer).

1. Once the container has started up, run the following script to log in to Azure using the Azure CLI and initialize the OpenTofu project.
   ```
   ./init.sh
   ```

1. Once this has completed, run the following script to deploy a demo setup to your Azure Subscription. 
   ```
   ./apply.sh
   ```

   The demo deployment will comprise:
   - A resource group (named `fctapp-opentofu-rg` by default), containing
   - a FunctionApp with System-Assigned Managed Identity entabled,
   - running a container built from the image defined in `container-image/Dockerfile` (containing Azure CLI and OpenTofu) and stored in a Container Registry
   - executing the Azure Function defined in `container-image/function_app.py` once every minute,
   - wrapping the execution of shell script  `container-image/tf-demo/deploy.sh`,
   - containing the invocation OpenTofu, trying to read `data "terraform_remote_state" "shared" {...}` as defined in `container-image/tf-demo/main.tf` using the FunctionApp's manged identity,
   - sending all logs to a Log Analytics Workspace for inspection.

1. After some minutes, open the FunctionApp and explore the logs using "Monitoring / Log stream". The function will trigger the OpenTofu invocation once a minute; it will show the error message:
   
   ```
   Error: Error building ARM Config: Authenticating using the Azure CLI is only supported as a User (not a Service Principal).
   
   To authenticate to Azure using a Service Principal, you can use the separate 'Authenticate using a Service Principal'
   auth method - instructions for which can be found here: https://registry.opentofu.org/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret
   
   Alternatively you can authenticate using the Azure CLI by using a User Account.
   
   
   Error: data.terraform_remote_state.shared: Unable to read remote state
   ```

1. After your testing, run following script to destroy the demo setup resources.
   ```
   ./destroy.sh
   ```

# Additional Context

- The error message is generated in file [`go-azure-helpers/authentication/auth_method_azure_cli_token.go`](https://github.com/hashicorp/go-azure-helpers/blob/v0.43.0/authentication/auth_method_azure_cli_token.go#L72) until version `v0.51.0` of library [hashicorp/go-azure-helpers](https://github.com/hashicorp/go-azure-helpers/tree/v0.52.0).
- To the best of our knowledge, OpenTofu uses version `v0.43.0` from October 2022 of this library today (see [`opentofu/go.mod`](https://github.com/opentofu/opentofu/blob/main/go.mod#L48C2-L48C47)) and therefore has this limitation.
- In the meantime, Hashicorp  has refactored the authentication in the newer libraries for Terraform; backend authentication is now implemented in [directory `go-azure-sdk/sdk/auth` in library `hashicorp/go-azure-sdk`](https://github.com/hashicorp/go-azure-sdk/tree/main/sdk/auth).
- Our testing revealed that the newer Terraform versions do not have this limitation; our use case above was successfully tested with version 1.12.2.
- It might be valuable to update the authentication procedure to also support authentication via Managed Identity from Azure CLI to retrieve `terraform_remote_state`.