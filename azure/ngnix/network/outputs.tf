output "virtual_network_name_out" {
  value = azurerm_virtual_network.virtual_network.name
}

output "nsg_name_out" {
  value = azurerm_network_security_group.nsg.name
}

output "public_ip_address_id_out" {
  value = azurerm_public_ip.public_ip_address.id
}

output "default_subnet_id_out" {
  value = azurerm_subnet.default_subnet_vnet.id
}

output "network_interface_card_id_out" {
  value = azurerm_network_interface.network_interface_card.id
}