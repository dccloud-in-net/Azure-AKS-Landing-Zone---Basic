output "resource_group_name" {
  description = "The name of the Resource Group created"
  value       = azurerm_resource_group.main.name
}

output "vnet_id" {
  description = "The ID of the Virtual Network"
  value       = module.networking.vnet_id
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value       = module.networking.subnet_ids
}

output "aks_cluster_name" {
  description = "The name of the AKS Cluster"
  value       = module.aks.cluster_name
}

output "aks_cluster_id" {
  description = "The ID of the AKS Cluster"
  value       = module.aks.cluster_id
}

output "aks_oidc_issuer_url" {
  description = "The OIDC issuer URL for Workload Identity configuration"
  value       = module.aks.oidc_issuer_url
}

output "aks_kubelet_identity_client_id" {
  description = "The client ID of the AKS Kubelet Identity"
  value       = module.identity.kubelet_identity_client_id
}

output "acr_login_server" {
  description = "The login server URL for the Azure Container Registry"
  value       = module.acr.acr_login_server
}

output "acr_id" {
  description = "The ID of the Container Registry"
  value       = module.acr.acr_id
}

output "key_vault_uri" {
  description = "The URI of the Key Vault"
  value       = module.security.key_vault_uri
}

output "key_vault_id" {
  description = "The ID of the Key Vault"
  value       = module.security.key_vault_id
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace"
  value       = module.monitoring.log_analytics_workspace_id
}

output "storage_account_name" {
  description = "The name of the Storage Account"
  value       = module.storage.storage_account_name
}
