variable "resource_group_name" {
  type        = string
  description = "The name of the Resource Group in which to create the resources"
}

variable "location" {
  type        = string
  description = "The Azure region where resources will be deployed"
}

variable "name_prefix" {
  type        = string
  description = "A naming prefix used for resources"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resources"
  default     = {}
}
