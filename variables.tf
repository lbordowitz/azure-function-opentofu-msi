####################################################
# VARIABLES
####################################################

variable "azure_subscription_id" {
  description = "The Azure subscription ID where resources will be deployed"
  type        = string
}

variable "service_prefix" {
  description = "Prefix to be used for naming resources (e.g., 'myapp', 'project1')"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be deployed"
  type        = string
  default     = "Sweden Central"
}

variable "acr_sku" {
  description = "The SKU name of the Azure Container Registry (Basic, Standard, Premium)"
  type        = string
  default     = "Basic"
}

variable "acr_admin_enabled" {
  description = "Specifies whether the admin user is enabled for the Azure Container Registry"
  type        = bool
  default     = false
}

