output "aks_identity_id" {
  description = "The Resource ID of the AKS Control Plane Identity"
  value       = azurerm_user_assigned_identity.aks.id
}

output "aks_identity_client_id" {
  description = "The Client ID of the AKS Control Plane Identity"
  value       = azurerm_user_assigned_identity.aks.client_id
}

output "aks_identity_principal_id" {
  description = "The Principal ID of the AKS Control Plane Identity"
  value       = azurerm_user_assigned_identity.aks.principal_id
}

output "kubelet_identity_id" {
  description = "The Resource ID of the AKS Kubelet Identity"
  value       = azurerm_user_assigned_identity.kubelet.id
}

output "kubelet_identity_client_id" {
  description = "The Client ID of the AKS Kubelet Identity"
  value       = azurerm_user_assigned_identity.kubelet.client_id
}

output "kubelet_identity_principal_id" {
  description = "The Principal ID of the AKS Kubelet Identity"
  value       = azurerm_user_assigned_identity.kubelet.principal_id
}
