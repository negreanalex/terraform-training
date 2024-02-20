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
  name = var.nsg
  resource_group_name = azurerm_resource_group.resource_group.name
  location = var.location
  depends_on = [ azurerm_virtual_network.virtual_network ]
}

resource "azurerm_network_security_rule" "nsg_rule_HTTP" {
  name                        = "AllowHTTP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.network_security_group.name
  depends_on = [ azurerm_network_security_group.network_security_group ]
}

resource "azurerm_network_security_rule" "nsg_rule_SSH" {
  name                        = "AllowSSH"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.network_security_group.name
  depends_on = [ azurerm_network_security_group.network_security_group ]
}

resource "azurerm_virtual_network" "virtual_network" {
  resource_group_name = azurerm_resource_group.resource_group.name
  location = var.location
  name = "vnet-wp-prod-001"
  address_space = [ "10.0.0.0/16" ]
  depends_on = [ azurerm_resource_group.resource_group ]
}

resource "azurerm_subnet" "subnet_frontend" {
  resource_group_name = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  name = "frontend"
  address_prefixes = [ "10.0.0.0/24" ]
  depends_on = [ azurerm_virtual_network.virtual_network ]
}

resource "azurerm_subnet" "subnet_backend" {
  resource_group_name = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  name = "backend"
  address_prefixes = [ "10.0.1.0/24" ]
  depends_on = [ azurerm_virtual_network.virtual_network ]
}

resource "azurerm_public_ip" "pip_nic1" {
  resource_group_name = azurerm_resource_group.resource_group.name
  location = var.location
  allocation_method = "Static"
  name = "pip-wp-001"
  depends_on = [ azurerm_virtual_network.virtual_network ]
}

resource "azurerm_public_ip" "pip_nic2" {
  resource_group_name = azurerm_resource_group.resource_group.name
  location = var.location
  allocation_method = "Static"
  name = "pip-db-001"
  depends_on = [ azurerm_virtual_network.virtual_network ]
}

resource "azurerm_network_interface" "network_interface_vm1" {
  resource_group_name = azurerm_resource_group.resource_group.name
  location = var.location
  name = "nic_vm1"

  ip_configuration {
    name = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    subnet_id = azurerm_subnet.subnet_frontend.id
    public_ip_address_id = azurerm_public_ip.pip_nic1.id
  }
  depends_on = [ azurerm_subnet.subnet_frontend ]
}

resource "azurerm_network_interface" "network_interface_vm2" {
  resource_group_name = azurerm_resource_group.resource_group.name
  location = var.location
  name = "nic_vm2"

  ip_configuration {
    name = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    subnet_id = azurerm_subnet.subnet_backend.id
    public_ip_address_id = azurerm_public_ip.pip_nic2.id
  }
  depends_on = [ azurerm_subnet.subnet_backend ]
}

resource "azurerm_subnet_network_security_group_association" "nsg_association_frontend" {
  network_security_group_id = azurerm_network_security_group.network_security_group.id
  subnet_id = azurerm_subnet.subnet_frontend.id
}

resource "azurerm_subnet_network_security_group_association" "nsg_association_backend" {
  network_security_group_id = azurerm_network_security_group.network_security_group.id
  subnet_id = azurerm_subnet.subnet_backend.id
}

resource "azurerm_network_interface_security_group_association" "nsg_association_nic_vm1" {
  network_security_group_id = azurerm_network_security_group.network_security_group.id
  network_interface_id = azurerm_network_interface.network_interface_vm1.id
}

resource "azurerm_network_interface_security_group_association" "nsg_association_nic_vm2" {
  network_security_group_id = azurerm_network_security_group.network_security_group.id
  network_interface_id = azurerm_network_interface.network_interface_vm2.id
}

resource "azurerm_key_vault" "key_vault" {
  name = "${var.kv_name}-${var.environment}-001"
  resource_group_name = azurerm_resource_group.resource_group.name
  location = var.location
  tenant_id = data.azurerm_client_config.current.tenant_id
  sku_name = var.kv_sku_name
  depends_on = [ azurerm_resource_group.resource_group ]
}

resource "azurerm_key_vault_access_policy" "key_vault_access_policy" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id
  depends_on = [ azurerm_key_vault.key_vault ]

  key_permissions = [ "Get" ]

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

resource "azurerm_key_vault_secret" "key_vault_secret_wp" {
  name = var.kv_secret_wp_name
  key_vault_id = azurerm_key_vault.key_vault.id
  value = random_password.password.result
  depends_on = [azurerm_key_vault_access_policy.key_vault_access_policy]
}

resource "azurerm_key_vault_secret" "key_vault_secret_db" {
  name = var.kv_secret_db_name
  key_vault_id = azurerm_key_vault.key_vault.id
  value = random_password.password.result
  depends_on = [ azurerm_key_vault_access_policy.key_vault_access_policy ]
}

resource "azurerm_linux_virtual_machine" "virtual_machine_wp" {
  name = "vm-wp"
  resource_group_name = azurerm_resource_group.resource_group.name
  location = var.location
  size = "Standard_B1s"
  disable_password_authentication = false
  admin_username = "azureadmin"
  admin_password = azurerm_key_vault_secret.key_vault_secret_wp.value
  network_interface_ids = [azurerm_network_interface.network_interface_vm1.id]
  custom_data = filebase64("wp.tpl")
  
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

resource "azurerm_linux_virtual_machine" "virtual_machine_db" {
  name = "vm-db"
  resource_group_name = azurerm_resource_group.resource_group.name
  location = var.location
  size = "Standard_B1s"
  disable_password_authentication = false
  admin_username = "azureadmin"
  admin_password = azurerm_key_vault_secret.key_vault_secret_db.value
  network_interface_ids = [azurerm_network_interface.network_interface_vm2.id]
  custom_data = filebase64("db.tpl")
  
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
