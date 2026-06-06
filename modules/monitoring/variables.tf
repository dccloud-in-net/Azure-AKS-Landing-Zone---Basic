variable "resource_group_name" {
  type        = string
  description = "The name of the Resource Group in which to create the resources"
}

variable "location" {
  type        = string
  description = "The Azure region where resources will be deployed"
}

variable "log_workspace_name" {
  type        = string
  description = "The name of the Log Analytics Workspace"
}

variable "retention_in_days" {
  type        = number
  description = "The workspace data retention in days"
  default     = 30
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource"
  default     = {}
}
