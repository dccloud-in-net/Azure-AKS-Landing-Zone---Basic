data "azurerm_client_config" "current" {}

# 1. Azure Key Vault
resource "azurerm_key_vault" "vault" {
  name                        = var.key_vault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = var.key_vault_sku

  # Enable RBAC control model instead of Access Policies (Modern Best Practice)
  enable_rbac_authorization  = true
  soft_delete_retention_days = 7
  purge_protection_enabled   = false # Set to true in prod if required

  # Network rules to lock down Key Vault access
  network_acls {
    bypass         = "AzureServices"
    default_action = var.enable_public_access ? "Allow" : "Deny"
  }

  tags = var.tags
}

# 2. Private Endpoint for Key Vault
resource "azurerm_private_endpoint" "vault_pe" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "pe-${var.key_vault_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-${var.key_vault_name}"
    private_connection_resource_id = azurerm_key_vault.vault.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_id_keyvault != null ? [1] : []
    content {
      name                 = "dns-group-keyvault"
      private_dns_zone_ids = [var.private_dns_zone_id_keyvault]
    }
  }

  tags = var.tags
}


# 3. Diagnostic Settings for Key Vault
resource "azurerm_monitor_diagnostic_setting" "kv_diags" {
  name                       = "ds-${var.key_vault_name}"
  target_resource_id         = azurerm_key_vault.vault.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  # Send audit events and logs
  enabled_log {
    category = "AuditEvent"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
