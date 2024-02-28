module "resource_group" {
  source   = "./resource_group"
  rg_name  = "rg-${var.project}-${local.dev.environment}-${var.location}"
  location = var.location
}

module "network" {
  source               = "./network"
  virtual_network_name = "vnet-${var.project}-${local.dev.environment}-${var.location}"
  resource_group       = module.resource_group.resource_group_name_out
  location             = module.resource_group.resource_group_location_out
  nsg_name             = "nsg-${var.project}-${local.dev.environment}-${var.location}"
  public_ip_name       = "pip-${var.project}-${local.dev.environment}-${var.location}"
  nic_name             = "nic-${var.project}-${local.dev.environment}-${var.location}"
}

module "virtual_machine" {
  source               = "./virtual-machines"
  virtual_machine_name = "vm-${var.project}-${local.dev.environment}"
  resource_group_name  = module.resource_group.resource_group_name_out
  location             = module.resource_group.resource_group_location_out
  size                 = local.dev.size
  admin_username       = var.admin_username
  admin_password       = var.admin_password
  nic_id               = module.network.network_interface_card_id_out
  os_disk_name         = local.dev.os_disk_name
  storage_account_type = local.dev.storage_account_type
  environment          = local.dev.environment
}

resource "azurerm_bastion_host" "bastion_host" {
  name                   = "bastion-${local.dev.environment}-${var.location}"
  resource_group_name    = module.resource_group.resource_group_name_out
  location               = module.resource_group.resource_group_location_out
  sku                    = "Standard"
  scale_units            = 2
  copy_paste_enabled     = true
  ip_connect_enabled     = true
  file_copy_enabled      = true
  shareable_link_enabled = true
  tunneling_enabled      = true

  ip_configuration {
    name                 = "bastion-config-01"
    subnet_id            = module.network.bastion_subnet_id_out
    public_ip_address_id = module.network.public_ip_address_id_out
  }
}