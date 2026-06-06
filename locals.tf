locals {
  # Standardized Naming Prefixes
  name_prefix = "${var.prefix}-${var.environment}"
  # Alphanumeric only, no hyphens for special resource types (ACR, Storage Account, Key Vault name rules)
  alphanumeric_prefix = replace(lower("${var.prefix}${var.environment}"), "[^a-z0-9]", "")

  # Resource Names conforming to CAF naming conventions
  resource_group_name  = "rg-${local.name_prefix}-aks-lz"
  vnet_name            = "vnet-${local.name_prefix}"
  aks_cluster_name     = "aks-${local.name_prefix}-cluster"
  acr_name             = "acr${local.alphanumeric_prefix}lz"
  key_vault_name       = "kv-${local.name_prefix}-lz"
  log_workspace_name   = "log-${local.name_prefix}-lz"
  storage_account_name = "st${local.alphanumeric_prefix}lz"
  nat_gateway_name     = "ngw-${local.name_prefix}"
  bastion_name         = "bas-${local.name_prefix}"

  # Default tags
  default_tags = merge({
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "AKS Landing Zone"
    Owner       = "Platform Engineering"
  }, var.tags)

  # ----------------------------------------------------------------------------
  # Student Subscription Compatibility Logic & Calculated Overrides
  # ----------------------------------------------------------------------------
  private_cluster_enabled      = var.azure_for_student ? false : var.private_cluster_enabled
  enable_bastion               = var.azure_for_student ? false : var.enable_bastion
  enable_nat_gateway           = var.azure_for_student ? false : var.enable_nat_gateway
  enable_private_endpoints     = var.azure_for_student ? false : var.enable_private_endpoints
  enable_entra_rbac            = var.azure_for_student ? false : var.enable_entra_rbac
  azure_policy_enabled         = var.azure_for_student ? false : var.azure_policy_enabled
  microsoft_defender_enabled   = var.azure_for_student ? false : var.microsoft_defender_enabled
  only_critical_addons_enabled = var.azure_for_student ? false : true

  # SKU Overrides
  acr_sku = var.azure_for_student ? "Basic" : var.acr_sku

  # Node sizing overrides to fit standard student subscription quota (4 vCPUs)
  aks_system_node_size  = var.azure_for_student ? "Standard_B2s" : var.aks_system_node_size
  aks_system_node_count = var.azure_for_student ? 1 : var.aks_system_node_count
  aks_user_node_pools   = var.azure_for_student ? {} : var.aks_user_node_pools
}

