locals {
  dev = {
    environment              = "dev"
    account_tier             = "Standard"
    account_replication_type = "LRS"
  }
  prod = {
    environment              = "prod"
    account_tier             = "Standard"
    account_replication_type = "GRS"
  }
}