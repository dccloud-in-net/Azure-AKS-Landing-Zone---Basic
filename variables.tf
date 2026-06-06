variable "prefix" {
  type        = string
  description = "A prefix used for naming resources to ensure uniqueness"
  default     = "contoso"
}

variable "environment" {
  type        = string
  description = "The deployment environment (e.g., dev, qa, prod)"
}

variable "location" {
  type        = string
  description = "The Azure region where resources will be deployed"
  default     = "eastus2"
}

# Networking Variables
variable "vnet_cidr" {
  type        = string
  description = "The CIDR block for the Virtual Network"
  default     = "10.0.0.0/16"
}

variable "subnets" {
  type = map(object({
    address_prefixes  = list(string)
    service_endpoints = optional(list(string), [])
    # Optional security configuration per subnet
    private_endpoint_network_policies_enabled     = optional(bool, true)
    private_link_service_network_policies_enabled = optional(bool, true)
  }))
  description = "A map of subnet configurations. Keys are subnet names, values are configurations."
}

# Monitoring Variables
variable "log_analytics_retention_days" {
  type        = number
  description = "The logging retention in days for the Log Analytics Workspace"
  default     = 30
}

# Storage Variables
variable "storage_account_tier" {
  type        = string
  description = "Defines the Tier to use for this storage account (Standard or Premium)"
  default     = "Standard"
}

variable "storage_account_replication_type" {
  type        = string
  description = "Defines the type of replication to use for this storage account (LRS, GRS, etc.)"
  default     = "LRS"
}

# ACR Variables
variable "acr_sku" {
  type        = string
  description = "The SKU of the Container Registry. Must be Premium for private link support."
  default     = "Premium"
}

# Key Vault Variables
variable "key_vault_sku" {
  type        = string
  description = "The SKU of the Key Vault (standard or premium)"
  default     = "standard"
}

# AKS Variables
variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version to use for the AKS cluster"
  default     = "1.29"
}

variable "aks_system_node_size" {
  type        = string
  description = "The VM size for the AKS system node pool"
  default     = "Standard_D2s_v5"
}

variable "aks_system_node_count" {
  type        = number
  description = "The initial number of nodes in the AKS system node pool"
  default     = 2
}

variable "aks_system_node_zones" {
  type        = list(string)
  description = "The availability zones for the system node pool"
  default     = ["1", "2", "3"]
}

variable "aks_user_node_pools" {
  type = map(object({
    vm_size         = string
    node_count      = number
    min_count       = number
    max_count       = number
    os_disk_size_gb = number
    zones           = list(string)
    node_labels     = optional(map(string), {})
    node_taints     = optional(list(string), [])
  }))
  description = "A map of user node pool configurations."
  default     = {}
}

variable "aks_admin_group_object_ids" {
  type        = list(string)
  description = "List of Azure AD Group Object IDs that should have Cluster Admin role on AKS"
  default     = []
}

# Global Tags
variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all resources"
  default     = {}
}

# ----------------------------------------------------------------------------
# Student Subscription & Cost/Quota Optimization Toggles
# ----------------------------------------------------------------------------

variable "azure_for_student" {
  type        = bool
  description = "Toggles between a lightweight student subscription friendly setup (false is enterprise-grade)"
  default     = true
}

variable "private_cluster_enabled" {
  type        = bool
  description = "Enable private AKS cluster (API server not exposed to public internet). Overridden to false if azure_for_student is true."
  default     = true
}

variable "enable_bastion" {
  type        = bool
  description = "Enable Azure Bastion Host. Overridden to false if azure_for_student is true."
  default     = true
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Enable NAT Gateway. Overridden to false if azure_for_student is true."
  default     = true
}

variable "enable_private_endpoints" {
  type        = bool
  description = "Enable Private Endpoints for PaaS resources (ACR, Key Vault, Storage). Overridden to false if azure_for_student is true."
  default     = true
}

variable "enable_entra_rbac" {
  type        = bool
  description = "Enable Microsoft Entra ID (Azure AD) Integrated RBAC. Overridden to false if azure_for_student is true."
  default     = true
}

variable "azure_policy_enabled" {
  type        = bool
  description = "Enable Azure Policy addon for AKS. Overridden to false if azure_for_student is true."
  default     = true
}

variable "microsoft_defender_enabled" {
  type        = bool
  description = "Enable Microsoft Defender for Containers. Overridden to false if azure_for_student is true."
  default     = true
}

