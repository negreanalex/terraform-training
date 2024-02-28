resource "azurerm_virtual_network" "virtual_network" {
  name = "${var.virtual_network_name}"
  resource_group_name = var.resource_group
  location = var.location
  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "default_subnet_vnet" {
    name = "default"
    resource_group_name = var.resource_group
    virtual_network_name = azurerm_virtual_network.virtual_network.name
    address_prefixes = ["10.0.0.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name = var.nsg_name
  resource_group_name = var.resource_group
  location = var.location
}

resource "azurerm_network_security_rule" "Allow_SSH" {
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name = var.resource_group
  name = "Allow_SSH"
  priority = 500
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = "22"
  source_address_prefix = "*"
  destination_address_prefixes = azurerm_subnet.default_subnet_vnet.address_prefixes
}

resource "azurerm_network_security_rule" "Allow_Outbound_All" {
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name = var.resource_group
  name = "Allow_Outbound_All"
  priority = 500
  direction = "Outbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = "*"
  source_address_prefixes = azurerm_subnet.default_subnet_vnet.address_prefixes
  destination_address_prefix = "*"
}

resource "azurerm_subnet_network_security_group_association" "nsg_association_subnet" {
  network_security_group_id = azurerm_network_security_group.nsg.id
  subnet_id = azurerm_subnet.default_subnet_vnet.id
}

resource "azurerm_public_ip" "public_ip_address_vm_agent" {
  name = var.public_ip_name
  resource_group_name = var.resource_group
  location = var.location
  allocation_method = "Static"
  sku = "Standard"
}

resource "azurerm_network_interface" "network_interface_card" {
  name = var.nic_name
  resource_group_name = var.resource_group
  location = var.location
  ip_configuration {
    name = "${var.nic_name}-configuration"
    subnet_id = azurerm_subnet.default_subnet_vnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public_ip_address_vm_agent.id
  }
}
