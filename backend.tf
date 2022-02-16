terraform {
  backend "azurerm" {
    resource_group_name  = "storage"
    storage_account_name = "bjgstorage999"
    container_name       = "terraform"
    key                  = "keyvault_IaC"
  }
}