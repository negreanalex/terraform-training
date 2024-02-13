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

resource "azurerm_resource_group" "resource_group" {
  name = "rg-ora-001"
  location = "eastus"
}

resource "azurerm_storage_account" "storage_account" {
  resource_group_name = azurerm_resource_group.resource_group.name
  location = azurerm_resource_group.resource_group.location

  
  name = "staccstatic001"
  account_tier = "Standard"
  account_replication_type = "LRS"
  account_kind = "StorageV2"

  static_website {
    index_document = "index.html"
  }
}

resource "azurerm_storage_blob" "web_container" {
    name = "index.html"
    storage_account_name = azurerm_storage_account.storage_account.name
    storage_container_name = "$web"
    type = "Block"
    content_type = "text/html"
    source = "index.html"
}

output "web_host" {
  value = azurerm_storage_account.storage_account.primary_web_host
}