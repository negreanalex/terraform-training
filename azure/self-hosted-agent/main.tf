module "resource_group" {
  source   = "./resource-group"
  rg_name  = "rg-${var.project}-${local.prod.environment}-${var.location}"
  location = var.location
}

module "network" {
  source               = "./network"
  virtual_network_name = "vnet-${var.project}-${local.prod.environment}-${var.location}"
  resource_group       = module.resource_group.resource_group_name_out
  location             = module.resource_group.resource_group_location_out
  nsg_name             = "nsg-${var.project}-${local.prod.environment}-${var.location}"
  public_ip_name       = "pip-${var.project}-${local.prod.environment}-${var.location}"
  nic_name             = "nic-${var.project}-${local.prod.environment}-${var.location}"
}

resource "azurerm_linux_virtual_machine" "self_hosted_agent_vm" {
  name                            = "vm-${var.project}-${local.prod.environment}"
  resource_group_name             = module.resource_group.resource_group_name_out
  location                        = module.resource_group.resource_group_location_out
  size                            = local.prod.size
  disable_password_authentication = false
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  network_interface_ids           = ["${module.network.network_interface_card_id_out}"]
  custom_data                     = filebase64("customdata.tpl")
  os_disk {
    name                 = local.prod.os_disk_name
    caching              = "ReadWrite"
    storage_account_type = local.prod.storage_account_type
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
