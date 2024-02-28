terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.91.0"
    }
  }
  backend "azurerm" {
    use_azuread_auth = true
    }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "resource_group" {
  location = "centralus"
  name     = "rg-test-010"
}