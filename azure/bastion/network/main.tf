resource "azurerm_virtual_network" "virtual_network" {
  name = "${var.virtual_network_name}"
  resource_group_name = var.resource_group
  location = var.location
  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "default_subnet_vnet" {
    name = local.default_vnet.default_subnet.name
    resource_group_name = var.resource_group
    virtual_network_name = azurerm_virtual_network.virtual_network.name
    address_prefixes = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "bastion_subnet_vnet" {
    name = local.default_vnet.bastion_subnet.name
    resource_group_name = var.resource_group
    virtual_network_name = azurerm_virtual_network.virtual_network.name
    address_prefixes = ["10.0.1.0/27"]
}

resource "azurerm_network_security_group" "nsg" {
  name = var.nsg_name
  resource_group_name = var.resource_group
  location = var.location
}

resource "azurerm_network_security_rule" "Inbound_Allow_RDP" {
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name = var.resource_group
  name = "Inbound_Allow_Bastion_RDP"
  priority = 500
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = "3389"
  source_address_prefixes = azurerm_subnet.bastion_subnet_vnet.address_prefixes
  destination_address_prefixes = azurerm_subnet.default_subnet_vnet.address_prefixes
}

resource "azurerm_network_security_rule" "Inbound_Deny_All" {
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name = var.resource_group
  name = "Inbound_Deny_Any_Any"
  priority = 600
  direction = "Inbound"
  access = "Deny"
  protocol = "*"
  source_port_range = "*"
  destination_port_range = "*"
  source_address_prefix = "*"
  destination_address_prefixes = azurerm_subnet.default_subnet_vnet.address_prefixes
}

resource "azurerm_network_security_rule" "Outbound_Allow_Subnet" {
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name = var.resource_group
  name = "Outbound_Allow_Subnet_Any"
  priority = 500
  direction = "Outbound"
  access = "Allow"
  protocol = "*"
  source_port_range = "*"
  destination_port_range = "*"
  source_address_prefixes = azurerm_subnet.default_subnet_vnet.address_prefixes
  destination_address_prefixes = azurerm_subnet.default_subnet_vnet.address_prefixes
}

resource "azurerm_network_security_rule" "Outbound_Deny_All" {
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name = var.resource_group
  name = "Outbound_Deny_Any_Any"
  priority = 600
  direction = "Outbound"
  access = "Deny"
  protocol = "*"
  source_port_range = "*"
  destination_port_range = "*"
  source_address_prefixes = azurerm_subnet.default_subnet_vnet.address_prefixes
  destination_address_prefix = "*"
}

resource "azurerm_subnet_network_security_group_association" "nsg_association_subnet" {
  network_security_group_id = azurerm_network_security_group.nsg.id
  subnet_id = azurerm_subnet.default_subnet_vnet.id
}

resource "azurerm_public_ip" "public_ip_address_bastion" {
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
  }
}




