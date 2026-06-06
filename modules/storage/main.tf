# 1. Secure Storage Account
resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication
  account_kind             = "StorageV2"

  https_traffic_only_enabled     = true
  min_tls_version               = "TLS1_2"
  public_network_access_enabled = var.enable_public_access

  network_rules {
    default_action = var.enable_public_access ? "Allow" : "Deny"
    bypass         = ["AzureServices"]
  }

  tags = var.tags
}

# 2. Private Endpoint for Storage Blob Service
resource "azurerm_private_endpoint" "storage_pe" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "pe-${var.storage_account_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-${var.storage_account_name}"
    private_connection_resource_id = azurerm_storage_account.storage.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_id_blob != null ? [1] : []
    content {
      name                 = "dns-group-blob"
      private_dns_zone_ids = [var.private_dns_zone_id_blob]
    }
  }

  tags = var.tags
}


# 3. Diagnostic Settings for Storage Account
resource "azurerm_monitor_diagnostic_setting" "storage_diags" {
  name                       = "ds-${var.storage_account_name}"
  target_resource_id         = azurerm_storage_account.storage.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
