####################################################
# PROVIDERS
####################################################

provider "azurerm" {
  subscription_id                 = var.azure_subscription_id
  resource_provider_registrations = "core"


  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.34.0"
    }
  }
}


####################################################
# RESOURCE GROUP
####################################################

resource "azurerm_resource_group" "main" {
  name     = "${var.service_prefix}-rg"
  location = var.location
}