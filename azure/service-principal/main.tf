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
  name                     = "stacc${var.location}${random_integer.resource_number.result}"
  resource_group_name      = module.resource_group.resource_group_name_out
  location                 = module.resource_group.resource_group_location_out
  account_replication_type = local.dev.account_replication_type
  account_tier             = local.dev.account_tier
  account_kind = local.dev.account_kind
  enable_https_traffic_only = true
  min_tls_version = "TLS1_2"
  shared_access_key_enabled = false
  default_to_oauth_authentication = true
  infrastructure_encryption_enabled = false

  blob_properties {
    versioning_enabled = true
    change_feed_enabled = true
    change_feed_retention_in_days = 90
    last_access_time_enabled = true

    delete_retention_policy {
      days = 30
    }

    container_delete_retention_policy {
      days = 30
    }
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
}