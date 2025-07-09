####################################################
# OUTPUTS
####################################################

output "rg_id" {
  description = "ID of the Resource Group where this demo setup is deployed."
  value       = azurerm_resource_group.main.id
}

output "acr_id" {
  description = "ID of the Azure Container Registry."
  value       = azurerm_container_registry.main.id
}

output "function_app_id" {
  description = "ID of the Azure Function App."
  value       = azurerm_linux_function_app.function_app.id
}

