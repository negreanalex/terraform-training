locals {
  default_vnet = {
    address_space = "10.0.0.0/16"
    default_subnet = {
        name = "default"
        address_prefixes = "10.0.0.0/24"
    }
    bastion_subnet = {
        name = "AzureBastionSubnet"
        address_prefixes = "10.0.1.0/27"
    }
  }
}