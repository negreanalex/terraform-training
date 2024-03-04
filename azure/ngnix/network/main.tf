resource "azurerm_virtual_network" "virtual_network" {
  name = "${var.virtual_network_name}"
  resource_group_name = var.resource_group
  location = var.location
  address_space = [ "10.0.0.0/16" ]
}

resource "azurerm_subnet" "subnet" {
  name = "default"
  resource_group_name = var.resource_group
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes = [ "10.0.0.0/24" ]
}

resource "azurerm_network_security_group" "nsg" {
  name = var.nsg_name
  resource_group_name = var.resource_group
  location = var.location
}

resource "azurerm_network_security_rule" "nsg_rule_SSH" {
  name                        = "AllowSSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name = var.resource_group
  network_security_group_name = azurerm_network_security_group.network_security_group.name
}

resource "azurerm_network_security_rule" "nsg_rule_8080" {
  name                        = "Allow8080"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8080"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.network_security_group.name
}

resource "azurerm_public_ip" "public_ip_address" {
  name = var.public_ip_name
  resource_group_name = var.resource_group
  location = var.location
  allocation_method = "Static"
}

resource "azurerm_network_interface" "network_interface_card" {
  name = var.nic_name
  resource_group_name = var.resource_group
  location = var.location
  ip_configuration {
    name = "ipconfig1"
    subnet_id = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public_ip_address.id
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_association_nic" {
  network_security_group_id = azurerm_network_security_group.nsg.id
  network_interface_id = azurerm_network_interface.network_interface_card.id
}