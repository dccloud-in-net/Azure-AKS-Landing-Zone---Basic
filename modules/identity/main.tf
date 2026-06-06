# 1. User Assigned Identity for AKS Control Plane
resource "azurerm_user_assigned_identity" "aks" {
  name                = "id-${var.name_prefix}-aks-cp"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# 2. User Assigned Identity for AKS Kubelet (Agent Pools)
resource "azurerm_user_assigned_identity" "kubelet" {
  name                = "id-${var.name_prefix}-aks-kubelet"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}
