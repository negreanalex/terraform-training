module "resource_group" {
  source = "./resource_group"
  rg_name = "rg-${var.project}-${local.dev.environment}-${var.location}"
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

resource "random_password" "password" {
  length = "16"
  special = true
  override_special = "!#$%&,."
}

resource "azurerm_linux_virtual_machine" "ngnix_vm" {
  name = "vm-${var.project}-${local.dev.environment}"
  resource_group_name = module.resource_group.resource_group_name_out
  location = module.resource_group.resource_group_location_out
  size = local.dev.size
  disable_password_authentication = false
  admin_username = var.admin_username
  admin_password = random_password.password.result
  network_interface_ids = ["${module.network.network_interface_card_id_out}"]
  custom_data = filebase64("customdata.tpl")
  os_disk {
    name = local.dev.os_disk_name
    caching = "ReadWrite"
    storage_account_type = local.dev.storage_account_type
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  tags = {
    environment = local.dev.environment
  }
}

