terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.91.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

module "resource_group" {
  source   = "./resource-group"
  location = var.location
  rg_name  = "rg-${var.project}-${local.dev.environment}-${var.location}"
}

resource "random_integer" "resource_number" {
  min = 000
  max = 100
}

resource "azurerm_storage_account" "storage_account" {
  name                     = "tfstate${local.dev.environment}${random_integer.resource_number.result}"
  resource_group_name      = module.resource_group.resource_group_name_out
  location                 = module.resource_group.resource_group_location_out
  account_replication_type = local.dev.account_replication_type
  account_tier             = local.dev.account_tier
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "blob"
}