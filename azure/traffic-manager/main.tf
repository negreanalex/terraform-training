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

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "resource_group_vm1" {
  name = "${var.rg_name}-${var.environment}-${var.location1}-${var.resource_number}"
  location = var.location1
}

resource "azurerm_resource_group" "resource_group_vm2" {
  name = "${var.rg_name}-${var.environment}-${var.location2}-${var.resource_number}"
  location = var.location2
}
