variable "resource_group_name" {
  type        = string
  description = "The name of the Resource Group in which to create the resources"
}

variable "location" {
  type        = string
  description = "The Azure region where resources will be deployed"
}

variable "vnet_name" {
  type        = string
  description = "The name of the Virtual Network"
}

variable "vnet_cidr" {
  type        = string
  description = "The CIDR block for the Virtual Network"
}

variable "subnets" {
  type = map(object({
    address_prefixes                              = list(string)
    service_endpoints                             = optional(list(string), [])
    private_endpoint_network_policies_enabled     = optional(bool, true)
    private_link_service_network_policies_enabled = optional(bool, true)
  }))
  description = "A map of subnet configurations"
}

variable "nat_gateway_name" {
  type        = string
  description = "The name of the NAT Gateway"
}

variable "bastion_name" {
  type        = string
  description = "The name of the Azure Bastion Host"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "The ID of the Log Analytics Workspace for diagnostics"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resources"
  default     = {}
}

variable "enable_bastion" {
  type        = bool
  description = "If true, deploy Azure Bastion Host"
  default     = true
}

variable "enable_nat_gateway" {
  type        = bool
  description = "If true, deploy NAT Gateway for AKS egress"
  default     = true
}

variable "enable_private_dns_zones" {
  type        = bool
  description = "If true, create and link Private DNS Zones"
  default     = true
}

