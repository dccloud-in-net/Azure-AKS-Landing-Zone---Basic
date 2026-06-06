# ----------------------------------------------------------------------------
# Azure AKS Landing Zone Root Orchestrator
# ----------------------------------------------------------------------------

# 1. Resource Group
resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.default_tags
}

# 2. Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  log_workspace_name  = local.log_workspace_name
  retention_in_days   = var.log_analytics_retention_days
  tags                = local.default_tags
}

# 3. Networking Module
module "networking" {
  source = "./modules/networking"

  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  vnet_name                  = local.vnet_name
  vnet_cidr                  = var.vnet_cidr
  subnets                    = var.subnets
  nat_gateway_name           = local.nat_gateway_name
  bastion_name               = local.bastion_name
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  
  # Student mode variables
  enable_bastion             = local.enable_bastion
  enable_nat_gateway         = local.enable_nat_gateway
  enable_private_dns_zones   = local.enable_private_endpoints

  tags                       = local.default_tags
}

# 4. Identity Module (Creates Managed Identities)
module "identity" {
  source = "./modules/identity"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  name_prefix         = local.name_prefix
  tags                = local.default_tags
}

# 5. Security Module (Key Vault)
module "security" {
  source = "./modules/security"

  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  key_vault_name               = local.key_vault_name
  key_vault_sku                = var.key_vault_sku
  private_endpoint_subnet_id   = local.enable_private_endpoints ? module.networking.subnet_ids["pe-subnet"] : null
  private_dns_zone_id_keyvault = local.enable_private_endpoints ? lookup(module.networking.private_dns_zone_ids, "vault", null) : null
  log_analytics_workspace_id   = module.monitoring.log_analytics_workspace_id
  
  # Student mode variables
  enable_private_endpoint      = local.enable_private_endpoints
  enable_public_access         = !local.enable_private_endpoints

  tags                         = local.default_tags
}

# 6. Container Registry Module
module "acr" {
  source = "./modules/acr"

  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  acr_name                   = local.acr_name
  acr_sku                    = local.acr_sku
  private_endpoint_subnet_id = local.enable_private_endpoints ? module.networking.subnet_ids["pe-subnet"] : null
  private_dns_zone_id_acr    = local.enable_private_endpoints ? lookup(module.networking.private_dns_zone_ids, "acr", null) : null
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  
  # Student mode variables
  enable_private_endpoint    = local.enable_private_endpoints
  enable_public_access       = !local.enable_private_endpoints

  tags                       = local.default_tags
}

# 7. Storage Module
module "storage" {
  source = "./modules/storage"

  resource_group_name         = azurerm_resource_group.main.name
  location                    = azurerm_resource_group.main.location
  storage_account_name        = local.storage_account_name
  storage_account_tier        = var.storage_account_tier
  storage_account_replication = var.storage_account_replication_type
  private_endpoint_subnet_id  = local.enable_private_endpoints ? module.networking.subnet_ids["pe-subnet"] : null
  private_dns_zone_id_blob    = local.enable_private_endpoints ? lookup(module.networking.private_dns_zone_ids, "blob", null) : null
  log_analytics_workspace_id  = module.monitoring.log_analytics_workspace_id
  
  # Student mode variables
  enable_private_endpoint     = local.enable_private_endpoints
  enable_public_access        = !local.enable_private_endpoints

  tags                        = local.default_tags
}

# 8. AKS Module
module "aks" {
  source = "./modules/aks"

  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  cluster_name               = local.aks_cluster_name
  kubernetes_version         = var.kubernetes_version
  vnet_subnet_id             = module.networking.subnet_ids["aks-subnet"]
  system_node_size           = local.aks_system_node_size
  system_node_count          = local.aks_system_node_count
  system_node_zones          = var.aks_system_node_zones
  user_node_pools            = local.aks_user_node_pools
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  key_vault_id               = module.security.key_vault_id
  admin_group_object_ids     = var.aks_admin_group_object_ids

  # Student mode variables
  private_cluster_enabled      = local.private_cluster_enabled
  enable_entra_rbac            = local.enable_entra_rbac
  azure_policy_enabled         = local.azure_policy_enabled
  microsoft_defender_enabled   = local.microsoft_defender_enabled
  only_critical_addons_enabled = local.only_critical_addons_enabled

  # Managed Identities created in Identity Module
  cluster_identity_id        = module.identity.aks_identity_id
  cluster_identity_client_id = module.identity.aks_identity_client_id
  kubelet_identity_id        = module.identity.kubelet_identity_id
  kubelet_identity_client_id = module.identity.kubelet_identity_client_id
  kubelet_identity_object_id = module.identity.kubelet_identity_principal_id

  tags = local.default_tags
}


# ----------------------------------------------------------------------------
# Role Assignments (Cross-Resource Permissions)
# ----------------------------------------------------------------------------

# AKS Kubelet Identity needs AcrPull permission on the Container Registry
resource "azurerm_role_assignment" "aks_kubelet_acr_pull" {
  scope                = module.acr.acr_id
  role_definition_name = "AcrPull"
  principal_id         = module.identity.kubelet_identity_principal_id
}

# AKS Identity needs Network Contributor on the VNet / AKS Subnet to manage routing/load balancers
resource "azurerm_role_assignment" "aks_identity_network_contributor" {
  scope                = module.networking.vnet_id
  role_definition_name = "Network Contributor"
  principal_id         = module.identity.aks_identity_principal_id
}

# Key Vault Secrets User for the AKS Key Vault CSI Secrets Store Provider
resource "azurerm_role_assignment" "aks_secrets_user" {
  scope                = module.security.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  # Assign to AKS AgentPool/Kubelet identity or user assigned workload identity.
  # Using AKS Kubelet Identity for CSI Secrets Store Provider integration:
  principal_id = module.identity.kubelet_identity_principal_id
}

# AKS Control Plane Identity needs Managed Identity Operator role on the Kubelet Identity to assign it
resource "azurerm_role_assignment" "aks_identity_kubelet_operator" {
  scope                = module.identity.kubelet_identity_id
  role_definition_name = "Managed Identity Operator"
  principal_id         = module.identity.aks_identity_principal_id
}

