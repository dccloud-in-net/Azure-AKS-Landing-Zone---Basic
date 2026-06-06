output "key_vault_id" {
  description = "The Resource ID of the Key Vault"
  value       = azurerm_key_vault.vault.id
}

output "key_vault_uri" {
  description = "The Vault URI (DNS Name)"
  value       = azurerm_key_vault.vault.vault_uri
}

output "key_vault_name" {
  description = "The name of the Key Vault"
  value       = azurerm_key_vault.vault.name
}
