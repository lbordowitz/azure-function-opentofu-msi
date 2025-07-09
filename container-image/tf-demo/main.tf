provider "azurerm" {
  subscription_id                 = var.azure_subscription_id
}

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.34.0"
    }
  }
}

resource "random_string" "random_suffix" {
  length  = 10
  special = false
  upper   = false
}

data "terraform_remote_state" "shared" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.backend_resource_group_name
    storage_account_name = var.backend_storage_account_name
    container_name       = var.backend_container_name
    key                  = var.backend_key
  }
}