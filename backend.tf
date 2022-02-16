terraform {
  backend "azurerm" {
    resource_group_name  = "Backstorage"
    storage_account_name = "thisisterraform98"
    container_name       = "tercont"
    key                  = "TerraSupreme"
  }
}