output "vnet_id" {
  description = "The ID of the Virtual Network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "The name of the Virtual Network"
  value       = azurerm_virtual_network.main.name
}

output "subnet_ids" {
  description = "A map of subnet names to subnet resource IDs"
  value       = { for name, subnet in azurerm_subnet.subnets : name => subnet.id }
}

output "private_dns_zone_ids" {
  description = "A map of Private DNS Zone names/keys to their resource IDs"
  value       = { for key, zone in azurerm_private_dns_zone.zones : key => zone.id }
}

output "private_dns_zone_names" {
  description = "A map of Private DNS Zone names/keys to their domain names"
  value       = { for key, zone in azurerm_private_dns_zone.zones : key => zone.name }
}

output "nat_gateway_public_ip" {
  description = "The public IP of the NAT Gateway"
  value       = length(azurerm_public_ip.nat) > 0 ? azurerm_public_ip.nat[0].ip_address : null
}

output "bastion_public_ip" {
  description = "The public IP of the Bastion Host (if deployed)"
  value       = length(azurerm_public_ip.bastion) > 0 ? azurerm_public_ip.bastion[0].ip_address : null
}

