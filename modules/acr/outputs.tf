output "acr_id" {
  description = "The Resource ID of the Container Registry"
  value       = azurerm_container_registry.acr.id
}

output "acr_login_server" {
  description = "The Login Server (URL) for the Container Registry"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_name" {
  description = "The name of the Container Registry"
  value       = azurerm_container_registry.acr.name
}
