output "cluster_id" {
  description = "The Resource ID of the AKS Cluster"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "cluster_name" {
  description = "The name of the AKS Cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "oidc_issuer_url" {
  description = "The OIDC Issuer URL of the AKS Cluster"
  value       = azurerm_kubernetes_cluster.aks.oidc_issuer_url
}

output "private_fqdn" {
  description = "The FQDN of the Private AKS Control Plane"
  value       = azurerm_kubernetes_cluster.aks.private_fqdn
}

output "node_resource_group" {
  description = "The auto-generated Resource Group containing the agent pool resources"
  value       = azurerm_kubernetes_cluster.aks.node_resource_group
}
