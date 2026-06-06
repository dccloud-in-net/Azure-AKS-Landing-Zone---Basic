variable "resource_group_name" {
  type        = string
  description = "The name of the Resource Group in which to create the resources"
}

variable "location" {
  type        = string
  description = "The Azure region where resources will be deployed"
}

variable "key_vault_name" {
  type        = string
  description = "The name of the Key Vault"
}

variable "key_vault_sku" {
  type        = string
  description = "The SKU of the Key Vault (standard or premium)"
  default     = "standard"
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "The Subnet ID where the Key Vault Private Endpoint should be created"
  default     = null
}

variable "private_dns_zone_id_keyvault" {
  type        = string
  description = "The Private DNS Zone ID for Key Vault"
  default     = null
}

variable "enable_private_endpoint" {
  type        = bool
  description = "If true, deploy Private Endpoint for Key Vault"
  default     = true
}

variable "enable_public_access" {
  type        = bool
  description = "If true, enable public network access to Key Vault"
  default     = false
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
