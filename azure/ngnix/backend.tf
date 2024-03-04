terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-dev-uksouth"
    storage_account_name = "tfstatedev49"
    container_name       = "tfstate"
    key                  = "terraform.tfstate6"
  }
}