variable "resource_group_name" {
  type        = string
  description = "The name of the Resource Group in which to create the resources"
}

variable "location" {
  type        = string
  description = "The Azure region where resources will be deployed"
}

variable "storage_account_name" {
  type        = string
  description = "The name of the Storage Account. Must be globally unique, lowercase, alphanumeric only."
}

variable "storage_account_tier" {
  type        = string
  description = "Defines the Tier to use for this storage account (Standard or Premium)"
  default     = "Standard"
}

variable "storage_account_replication" {
  type        = string
  description = "Defines the type of replication to use for this storage account (LRS, GRS, ZRS, RAGRS)"
  default     = "LRS"
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "The Subnet ID where the Storage Private Endpoint should be created"
  default     = null
}

variable "private_dns_zone_id_blob" {
  type        = string
  description = "The Private DNS Zone ID for Blob Storage"
  default     = null
}

variable "enable_private_endpoint" {
  type        = bool
  description = "If true, deploy Private Endpoint for Storage Account"
  default     = true
}

variable "enable_public_access" {
  type        = bool
  description = "If true, enable public network access to Storage Account"
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
