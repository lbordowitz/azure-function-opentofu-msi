####################################################
# VARIABLES
####################################################

variable "azure_subscription_id" {
  description = "The Azure subscription ID where resources will be deployed"
  type        = string
}

variable "backend_resource_group_name" {
  description = "The resource group name for the backend storage."
  type        = string
}

variable "backend_storage_account_name" {
  description = "The storrage account name for the backend storage."
  type        = string
}

variable "backend_container_name" {
  description = "The storage account container name for the backend storage."
  type        = string
}

variable "backend_key" {
  description = "The name of the state store."
  type        = string
}
