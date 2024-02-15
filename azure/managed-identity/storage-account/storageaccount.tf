terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.91.0"
    }
  }
}

provider "azurerm" {
    features {}
    skip_provider_registration = true
}

resource "azurerm_storage_account" "stdataoraalx0011" {
  name = "stnegreanalex001"
  resource_group_name = "rg-ora-001"
  location = "westeurope"
  account_replication_type = "LRS"
  account_tier = "Standard"
}