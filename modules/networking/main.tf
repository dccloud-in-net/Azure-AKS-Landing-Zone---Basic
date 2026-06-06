# 1. Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.vnet_cidr]
  tags                = var.tags
}

# 2. Subnets (Created via for_each)
resource "azurerm_subnet" "subnets" {
  for_each             = var.subnets
  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = each.value.address_prefixes
  service_endpoints    = each.value.service_endpoints

  private_endpoint_network_policies_enabled     = each.value.private_endpoint_network_policies_enabled
  private_link_service_network_policies_enabled = each.value.private_link_service_network_policies_enabled
}

# 3. NAT Gateway for AKS Subnet Egress
resource "azurerm_public_ip" "nat" {
  count               = var.enable_nat_gateway ? 1 : 0
  name                = "pip-${var.nat_gateway_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway" "nat" {
  count                   = var.enable_nat_gateway ? 1 : 0
  name                    = var.nat_gateway_name
  location                = var.location
  resource_group_name     = var.resource_group_name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 4
  tags                    = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "nat_pip" {
  count                = var.enable_nat_gateway ? 1 : 0
  nat_gateway_id       = azurerm_nat_gateway.nat[0].id
  public_ip_address_id = azurerm_public_ip.nat[0].id
}

# Associate NAT Gateway with AKS Subnet
resource "azurerm_subnet_nat_gateway_association" "aks" {
  count          = var.enable_nat_gateway && lookup(var.subnets, "aks-subnet", null) != null ? 1 : 0
  subnet_id      = azurerm_subnet.subnets["aks-subnet"].id
  nat_gateway_id = azurerm_nat_gateway.nat[0].id
}

# 4. Route Table for AKS Subnet
resource "azurerm_route_table" "aks" {
  name                          = "rt-${var.vnet_name}-aks"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  bgp_route_propagation_enabled = true

  route {
    name           = "internet-via-nat"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet" # NAT Gateway will automatically attract this traffic if associated, otherwise goes directly
  }

  tags = var.tags
}

resource "azurerm_subnet_route_table_association" "aks" {
  count          = lookup(var.subnets, "aks-subnet", null) != null ? 1 : 0
  subnet_id      = azurerm_subnet.subnets["aks-subnet"].id
  route_table_id = azurerm_route_table.aks.id
}

# 5. Azure Bastion (Optional - only deployed if AzureBastionSubnet is provided)
resource "azurerm_public_ip" "bastion" {
  count               = var.enable_bastion && lookup(var.subnets, "AzureBastionSubnet", null) != null ? 1 : 0
  name                = "pip-${var.bastion_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_bastion_host" "bastion" {
  count               = var.enable_bastion && lookup(var.subnets, "AzureBastionSubnet", null) != null ? 1 : 0
  name                = var.bastion_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  ip_configuration {
    name                 = "bastion_ip_config"
    subnet_id            = azurerm_subnet.subnets["AzureBastionSubnet"].id
    public_ip_address_id = azurerm_public_ip.bastion[0].id
  }

  tags = var.tags
}

# 6. Private DNS Zones for PaaS Services & AKS Private Link
locals {
  private_dns_zones = {
    "vault" = "privatelink.vaultcore.azure.net"
    "acr"   = "privatelink.azurecr.io"
    "blob"  = "privatelink.blob.core.windows.net"
    "aks"   = "privatelink.${var.location}.azmk8s.io"
  }
}

resource "azurerm_private_dns_zone" "zones" {
  for_each            = var.enable_private_dns_zones ? local.private_dns_zones : {}
  name                = each.value
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Link Private DNS Zones to the VNet
resource "azurerm_private_dns_zone_virtual_network_link" "links" {
  for_each              = azurerm_private_dns_zone.zones
  name                  = "link-${each.key}-${var.vnet_name}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = each.value.name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled  = false
  tags                  = var.tags
}

