# 1. Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                          = var.acr_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = var.acr_sku
  admin_enabled                 = false # Secure by default: disable local admin credentials
  public_network_access_enabled = var.acr_sku == "Premium" ? var.enable_public_access : true

  tags = var.tags
}

# 2. Private Endpoint for Container Registry
resource "azurerm_private_endpoint" "acr_pe" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "pe-${var.acr_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-${var.acr_name}"
    private_connection_resource_id = azurerm_container_registry.acr.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_id_acr != null ? [1] : []
    content {
      name                 = "dns-group-acr"
      private_dns_zone_ids = [var.private_dns_zone_id_acr]
    }
  }

  tags = var.tags
}


# 3. Diagnostic Settings for Container Registry
resource "azurerm_monitor_diagnostic_setting" "acr_diags" {
  name                       = "ds-${var.acr_name}"
  target_resource_id         = azurerm_container_registry.acr.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "ContainerRegistryRepositoryEvents"
  }

  enabled_log {
    category = "ContainerRegistryLoginEvents"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
