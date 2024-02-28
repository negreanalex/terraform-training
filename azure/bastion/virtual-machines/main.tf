resource "azurerm_windows_virtual_machine" "virtual_machine" {
  name = var.virtual_machine_name
  resource_group_name = var.resource_group_name
  location = var.location
  size = var.size
  admin_username = var.admin_username
  admin_password = var.admin_password
  network_interface_ids = [var.nic_id]
  os_disk {
    name = var.os_disk_name
    caching = "ReadWrite"
    storage_account_type = var.storage_account_type
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
  tags = {
    environment = var.environment
  }
}