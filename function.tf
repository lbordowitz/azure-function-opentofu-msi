####################################################
# AZURE CONTAINER REGISTRY
####################################################

resource "azurerm_container_registry" "main" {
  name                = "${replace(var.service_prefix, "-", "")}acr"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = var.acr_sku
  admin_enabled       = var.acr_admin_enabled
}

locals {
  image_name = "fct-app-with-opentofu"
  image_tag  = "latest"
}

resource "null_resource" "build_container_image" {
  triggers = {
    image_name = local.image_name
    image_tag  = local.image_tag
  }
  provisioner "local-exec" {
    command     = "az acr build -t ${local.image_name}:${local.image_tag} -r ${azurerm_container_registry.main.name} -f ${path.cwd}/container-image/Dockerfile ./container-image"
    interpreter = ["bash", "-c"]
  }
  depends_on = [azurerm_container_registry.main]
}

####################################################
# STORAGE ACCOUNT FOR FUNCTION APP
####################################################

resource "azurerm_storage_account" "fct_app_storage" {
  name                            = substr(replace("${var.service_prefix}-fctapp", "-", ""), 0, 20)
  location                        = azurerm_resource_group.main.location
  resource_group_name             = azurerm_resource_group.main.name
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
}

resource "azurerm_storage_container" "state_container" {
  name                  = "state-container"
  storage_account_id    = azurerm_storage_account.fct_app_storage.id
  container_access_type = "private"
}

####################################################
# SERVICE PLAN (LINUX FOR DOCKER SUPPORT)
####################################################

resource "azurerm_service_plan" "hosting_plan" {
  name                = "${var.service_prefix}-plan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  sku_name = "EP1"
  os_type  = "Linux"
}

####################################################
# FUNCTION APP WITH DOCKER SUPPORT
####################################################

resource "azurerm_linux_function_app" "function_app" {
  name                = "${var.service_prefix}-func"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.hosting_plan.id

  storage_account_name       = azurerm_storage_account.fct_app_storage.name
  storage_account_access_key = azurerm_storage_account.fct_app_storage.primary_access_key

  identity {
    type = "SystemAssigned"
  }

  site_config {
    container_registry_use_managed_identity = true
    always_on                               = true

    application_stack {
      docker {
        registry_url = azurerm_container_registry.main.login_server
        image_name   = local.image_name
        image_tag    = local.image_tag
      }
    }

    application_insights_connection_string = azurerm_application_insights.application_insights.connection_string
    application_insights_key               = azurerm_application_insights.application_insights.instrumentation_key
  }

  app_settings = {
    "FUNCTIONS_EXTENSION_VERSION"         = "~4"
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "DOCKER_REGISTRY_SERVER_URL"          = azurerm_container_registry.main.login_server
    "SCM_DO_BUILD_DURING_DEPLOYMENT"      = "false"
    "ENABLE_ORYX_BUILD"                   = "false"

    "BACKEND_RESOURCE_GROUP_NAME"  = azurerm_resource_group.main.name
    "BACKEND_STORAGE_ACCOUNT_NAME" = azurerm_storage_account.fct_app_storage.name
    "BACKEND_CONTAINER_NAME"       = azurerm_storage_container.state_container.name
    "BACKEND_KEY"                  = "tf-demo.tfstate"
  }

  depends_on = [
    null_resource.build_container_image
  ]
}

####################################################
# RBAC - FUNCTION APP ACCESS TO ACR
####################################################

resource "azurerm_role_assignment" "function_app_acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_function_app.function_app.identity[0].principal_id
}

####################################################
# RBAC - FUNCTION APP ACCESS TO RESOURCE GROUP
####################################################

resource "azurerm_role_assignment" "function_app_rg_contributor" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_linux_function_app.function_app.identity[0].principal_id
}

######################################################
# LOG ANALYTICS WORKSPACE
######################################################

resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.service_prefix}-law"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "application_insights" {
  name                = "${var.service_prefix}-appin"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  workspace_id        = azurerm_log_analytics_workspace.law.id
  application_type    = "web"
}
