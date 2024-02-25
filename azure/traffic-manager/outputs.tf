output "admin_password_vm_iis_1" {
    sensitive = true
    value = azurerm_windows_virtual_machine.virtual_machine_iis_1.admin_password
}

output "public_ip_vm_iis_1" {
  value = azurerm_windows_virtual_machine.virtual_machine_iis_1.public_ip_address
}

output "admin_password_vm_iis_2" {
    sensitive = true
    value = azurerm_windows_virtual_machine.virtual_machine_iis_2.admin_password
}

output "public_ip_vm_iis_2" {
  value = azurerm_windows_virtual_machine.virtual_machine_iis_2.public_ip_address
}