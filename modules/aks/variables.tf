variable "resource_group_name" {
  type        = string
  description = "The name of the Resource Group in which to create the resources"
}

variable "location" {
  type        = string
  description = "The Azure region where resources will be deployed"
}

variable "cluster_name" {
  type        = string
  description = "The name of the AKS Cluster"
}

variable "kubernetes_version" {
  type        = string
  description = "The Kubernetes version for the cluster"
  default     = "1.29"
}

variable "vnet_subnet_id" {
  type        = string
  description = "The Subnet ID where the AKS cluster nodes will reside"
}

variable "system_node_size" {
  type        = string
  description = "The VM size for the system node pool"
  default     = "Standard_D2s_v5"
}

variable "system_node_count" {
  type        = number
  description = "The initial node count for the system node pool"
  default     = 2
}

variable "user_node_pools" {
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
  description = "Map of user node pools to create"
  default     = {}
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "The ID of the Log Analytics Workspace for diagnostics and monitoring"
}

variable "key_vault_id" {
  type        = string
  description = "The ID of the Key Vault for CSI Secret Store Driver access"
}

variable "admin_group_object_ids" {
  type        = list(string)
  description = "The list of Azure AD Group Object IDs that have Cluster Admin role on AKS"
  default     = []
}

variable "cluster_identity_id" {
  type        = string
  description = "The Resource ID of the User Assigned Identity for the AKS Control Plane"
}

variable "cluster_identity_client_id" {
  type        = string
  description = "The Client ID of the User Assigned Identity for the AKS Control Plane"
}

variable "kubelet_identity_id" {
  type        = string
  description = "The Resource ID of the User Assigned Identity for the AKS Kubelet"
}

variable "kubelet_identity_client_id" {
  type        = string
  description = "The Client ID of the User Assigned Identity for the AKS Kubelet"
}

variable "kubelet_identity_object_id" {
  type        = string
  description = "The Object ID (Principal ID) of the User Assigned Identity for the AKS Kubelet"
}

variable "system_node_zones" {
  type        = list(string)
  description = "The availability zones for the system node pool"
  default     = ["1", "2", "3"]
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resources"
  default     = {}
}

variable "private_cluster_enabled" {
  type        = bool
  description = "If true, the AKS cluster API server is private"
  default     = true
}

variable "enable_entra_rbac" {
  type        = bool
  description = "If true, enable Entra ID Integrated RBAC"
  default     = true
}

variable "azure_policy_enabled" {
  type        = bool
  description = "If true, enable Azure Policy addon for Kubernetes"
  default     = true
}

variable "microsoft_defender_enabled" {
  type        = bool
  description = "If true, enable Microsoft Defender for Containers"
  default     = true
}

variable "only_critical_addons_enabled" {
  type        = bool
  description = "If true, system node pool will only run critical system pods"
  default     = true
}

