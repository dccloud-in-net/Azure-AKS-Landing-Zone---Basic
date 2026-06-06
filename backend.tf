# Remote backend configuration for Azure Storage Account
# Settings (resource_group_name, storage_account_name, container_name, key) 
# should be provided via backend configuration files or CLI options.
terraform {
  backend "azurerm" {}
}

