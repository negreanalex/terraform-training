output "virtual_machine_name" {
  value = azurerm_linux_virtual_machine.ngnix_vm.name
}

output "virtual_machine_pip" {
  value = azurerm_linux_virtual_machine.ngnix_vm.public_ip_address
}

output "virtual_machine_admin_password" {
  value = azurerm_linux_virtual_machine.ngnix_vm.admin_password
  sensitive = true
}