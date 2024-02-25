terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.91.0"
    }
  }
}

provider "azurerm" {
    features {}
    skip_provider_registration = true
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "resource_group" {
  name = var.rg_name
  location = var.location
}

resource "azurerm_network_security_group" "network_security_group" {
  name = "NSG-${var.workload}-${var.environment}"
  resource_group_name = azurerm_resource_group.resource_group.name
  location = azurerm_resource_group.resource_group.location
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
  resource_group_name = azurerm_resource_group.resource_group.name
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

resource "azurerm_virtual_network" "virtual_network" {
  resource_group_name = azurerm_resource_group.resource_group.name
  location = azurerm_resource_group.resource_group.location
  name = "vnet-${var.workload}-${var.environment}-${var.location}"
  address_space = [ "10.0.0.0/16" ]
}

resource "azurerm_subnet" "subnet" {
  resource_group_name = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  name = "default"
  address_prefixes = [ "10.0.0.0/24" ]
}

resource "azurerm_public_ip" "pip_nic" {
  resource_group_name = azurerm_resource_group.resource_group.name
  location = azurerm_resource_group.resource_group.location
  allocation_method = "Static"
  name = "pip-${var.workload}-${var.environment}-${var.location}"
}

resource "azurerm_network_interface" "network_interface" {
  resource_group_name = azurerm_resource_group.resource_group.name
  location = azurerm_resource_group.resource_group.location
  name = "nic-${var.workload}-${var.environment}"

  ip_configuration {
    name = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    subnet_id = azurerm_subnet.subnet.id
    public_ip_address_id = azurerm_public_ip.pip_nic.id
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_association_nic_vm1" {
  network_security_group_id = azurerm_network_security_group.network_security_group.id
  network_interface_id = azurerm_network_interface.network_interface.id
}

resource "random_password" "password" {
  length = "16"
  special = true
  override_special = "!#$%&,."
}

resource "azurerm_linux_virtual_machine" "virtual_machine_jenkins" {
  name = "vm-${var.workload}-${var.environment}-${var.location}"
  resource_group_name = azurerm_resource_group.resource_group.name
  location = azurerm_resource_group.resource_group.location
  size = "Standard_B1s"
  disable_password_authentication = false
  admin_username = "azureadmin"
  admin_password = random_password.password.result
  network_interface_ids = [azurerm_network_interface.network_interface.id]
  custom_data = filebase64("customdata.tpl")
  
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

   source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

