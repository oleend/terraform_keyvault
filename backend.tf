terraform {
  backend "azurerm" {
    resource_group_name  = "terraform_backend"
    storage_account_name = "bjgterraformbackend"
    container_name       = "terraform"
    key                  = "hybrid_IaC"
  }
}