# 1. Private AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                    = var.cluster_name
  location                = var.location
  resource_group_name     = var.resource_group_name
  dns_prefix              = var.cluster_name
  kubernetes_version      = var.kubernetes_version
  private_cluster_enabled = var.private_cluster_enabled

  # Enable OIDC Issuer and Workload Identity (Modern Security)
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  # Enable Azure Policy for kubernetes clusters (governance & compliance)
  azure_policy_enabled = var.azure_policy_enabled

  # Managed identities for AKS
  identity {
    type         = "UserAssigned"
    identity_ids = [var.cluster_identity_id]
  }

  kubelet_identity {
    client_id                 = var.kubelet_identity_client_id
    object_id                 = var.kubelet_identity_object_id
    user_assigned_identity_id = var.kubelet_identity_id
  }

  # Dedicated System Node Pool (Only runs system components, no application pods)
  default_node_pool {
    name                = "systempool"
    vm_size             = var.system_node_size
    node_count          = var.system_node_count
    vnet_subnet_id      = var.vnet_subnet_id
    zones               = var.system_node_zones
    enable_auto_scaling = false
    type                = "VirtualMachineScaleSets"
    os_disk_size_gb     = 128

    # Reserve this pool exclusively for system pods (only when configured)
    only_critical_addons_enabled = var.only_critical_addons_enabled
    tags                         = var.tags
  }

  # Azure CNI Overlay for High Performance and IP conservation
  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "azure" # Azure Network Policies for Pod-level zero-trust segmentations
    load_balancer_sku   = "standard"
  }

  # Microsoft Entra ID (Azure AD) Integrated RBAC
  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.enable_entra_rbac ? [1] : []
    content {
      managed                = true
      azure_rbac_enabled     = true
      admin_group_object_ids = var.admin_group_object_ids
    }
  }

  # Azure Key Vault Secrets Store CSI Driver integration
  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  # Defender for Containers setup
  dynamic "microsoft_defender" {
    for_each = var.microsoft_defender_enabled ? [1] : []
    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }


  tags = var.tags

  # Wait for proper role assignments to complete
  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count
    ]
  }
}

# 2. User Node Pools (Created via for_each for application workloads)
resource "azurerm_kubernetes_cluster_node_pool" "userpools" {
  for_each              = var.user_node_pools
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  name                  = each.key
  vm_size               = each.value.vm_size
  node_count            = each.value.node_count
  vnet_subnet_id        = var.vnet_subnet_id
  enable_auto_scaling   = true
  min_count             = each.value.min_count
  max_count             = each.value.max_count
  os_disk_size_gb       = each.value.os_disk_size_gb
  zones                 = each.value.zones
  node_labels           = each.value.node_labels
  node_taints           = each.value.node_taints

  tags = var.tags
}

# 3. Diagnostic Settings for AKS Control Plane Logs & Metrics
locals {
  aks_diagnostic_logs = [
    "kube-apiserver",
    "kube-audit",
    "kube-audit-admin",
    "kube-controller-manager",
    "cluster-autoscaler"
  ]
}

resource "azurerm_monitor_diagnostic_setting" "aks" {
  name                       = "ds-${var.cluster_name}"
  target_resource_id         = azurerm_kubernetes_cluster.aks.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = local.aks_diagnostic_logs
    content {
      category = enabled_log.value
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
