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

resource "azurerm_network_security_group" "network_security_group" {
  name = var.nsg
  resource_group_name = var.rg_name
  location = var.location
}

resource "azurerm_network_security_rule" "example" {
  name                        = "AllowRDP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.network_security_group.name
}

resource "azurerm_virtual_network" "virtual_network" {
  resource_group_name = var.rg_name
  location = var.location
  name = "vnet1"
  address_space = [ "10.0.0.0/16" ]
}

resource "azurerm_subnet" "subnet" {
  resource_group_name = var.rg_name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  name = "default"
  address_prefixes = [ "10.0.1.0/24" ]
}

resource "azurerm_network_interface" "network_interface1" {
  resource_group_name = var.rg_name
  location = var.location
  name = "nic1"

  ip_configuration {
    name = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    subnet_id = azurerm_subnet.subnet.id
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_association" {
  network_security_group_id = azurerm_network_security_group.network_security_group.id
  network_interface_id = azurerm_network_interface.network_interface1.id
}

resource "azurerm_user_assigned_identity" "managed-identity" {
  location            = var.location
  name                = "MythicalUAMI001"
  resource_group_name = var.rg_name
}

resource "azurerm_key_vault" "key_vault" {
  name = "${var.kv_name}-${var.environment}-001"
  resource_group_name = var.rg_name
  location = var.location
  tenant_id = data.azurerm_client_config.current.tenant_id
  sku_name = var.kv_sku_name
}

resource "azurerm_key_vault_access_policy" "key_vault_access_policy" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Set",
    "Get",
    "Delete",
    "Purge",
    "Recover",
    "List"
  ]
}

resource "random_password" "password" {
  length = "16"
  special = true
  override_special = "!#$%&,."
}

resource "azurerm_key_vault_secret" "key_vault_secret" {
  name = var.kv_secret_name
  key_vault_id = azurerm_key_vault.key_vault.id
  value = random_password.password.result
}

resource "azurerm_windows_virtual_machine" "virtual_machine" {
  name = "MythicalVM001"
  resource_group_name = "257-d51a5c9a-create-a-managed-identity"
  location = "westus"
  size = "B2ms"
  admin_username = "azureadmin"
  admin_password = azurerm_key_vault_secret.key_vault_secret.value
  network_interface_ids = [azurerm_network_interface.network_interface1.id,]
  
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

