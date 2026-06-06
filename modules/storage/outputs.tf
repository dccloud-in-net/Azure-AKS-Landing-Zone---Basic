output "storage_account_id" {
  description = "The Resource ID of the Storage Account"
  value       = azurerm_storage_account.storage.id
}

output "storage_account_name" {
  description = "The name of the Storage Account"
  value       = azurerm_storage_account.storage.name
}

output "primary_blob_endpoint" {
  description = "The endpoint URL for the blob storage service"
  value       = azurerm_storage_account.storage.primary_blob_endpoint
}
