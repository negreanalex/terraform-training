output "admin_password" {
  sensitive = true
  value = azurerm_linux_virtual_machine.virtual_machine_jenkins.admin_password
}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.virtual_machine_jenkins.public_ip_address
}