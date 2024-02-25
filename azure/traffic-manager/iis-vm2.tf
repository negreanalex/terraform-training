resource "azurerm_virtual_network" "virtual_network_iis_2" {
  name = "${var.virtual_network2}-${var.environment}-${var.location2}-${var.resource_number2}"
  resource_group_name = azurerm_resource_group.resource_group_vm2.name
  location = azurerm_resource_group.resource_group_vm2.location
  address_space = [ "10.0.0.0/16" ]
}

resource "azurerm_subnet" "subnet_vnet2" {
  name = "default"
  resource_group_name = azurerm_resource_group.resource_group_vm2.name
  virtual_network_name = azurerm_virtual_network.virtual_network_iis_2.name
  address_prefixes = [ "10.0.0.0/24" ]
}

resource "azurerm_network_security_group" "nsg2" {
  name = "nsg-${var.virtual_network1}"
  resource_group_name = azurerm_resource_group.resource_group_vm2.name
  location = azurerm_resource_group.resource_group_vm2.location
}

resource "azurerm_network_security_rule" "nsg2_rule_RDP" {
  name                        = "AllowRDP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.resource_group_vm2.name
  network_security_group_name = azurerm_network_security_group.nsg2.name
}

resource "azurerm_network_security_rule" "nsg2_rule_HTTP" {
  name                        = "AllowHTTP"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.resource_group_vm2.name
  network_security_group_name = azurerm_network_security_group.nsg2.name
}

resource "azurerm_public_ip" "public_ip_vm_iis_2" {
  name = "pip-${var.environment}-${var.resource_number2}"
  resource_group_name = azurerm_resource_group.resource_group_vm2.name
  location = azurerm_resource_group.resource_group_vm2.location
  allocation_method = "Static"
}

resource "azurerm_network_interface" "network_interface_iis_2" {
  name = "nic-${var.resource_number2}"
  location = azurerm_resource_group.resource_group_vm2.location
  resource_group_name = azurerm_resource_group.resource_group_vm2.name
  ip_configuration {
    name = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    subnet_id = azurerm_subnet.subnet_vnet2.id
    public_ip_address_id = azurerm_public_ip.public_ip_vm_iis_2.id
  }
}

resource "azurerm_network_interface_security_group_association" "nic2-nsg_association" {
  network_interface_id = azurerm_network_interface.network_interface_iis_2.id
  network_security_group_id = azurerm_network_security_group.nsg2.id
}

resource "random_password" "password_iis_2" {
  length = "16"
  special = true
  override_special = "!#$%&,."
}

resource "azurerm_windows_virtual_machine" "virtual_machine_iis_2" {
  name = "vm-iis-${var.resource_number2}"
  resource_group_name = azurerm_resource_group.resource_group_vm2.name
  location = azurerm_resource_group.resource_group_vm2.location
  size = "Standard_B1s"
  admin_username = "azureadmin"
  admin_password = random_password.password_iis_2.result
  network_interface_ids = [azurerm_network_interface.network_interface_iis_2.id]
  
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}