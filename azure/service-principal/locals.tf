locals {
  dev = {
    environment              = "dev"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    account_kind = "StorageV2"
  }
  prod = {
    environment              = "prod"
    account_tier             = "Standard"
    account_replication_type = "GRS"
    account_kind = "StorageV2"
  }
}