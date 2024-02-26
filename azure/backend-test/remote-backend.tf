terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.91.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-dev-uksouth"
    storage_account_name = "tfstatedev49"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

resource "azurerm_resource_group" "resource_group" {
  location = "centralus"
  name     = "rg-test-007"
}