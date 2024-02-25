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

resource "azurerm_virtual_network" "virtual_network" {
  name = var.vnet_name
  resource_group_name = azurerm_resource_group.resource_group.name
  location = azurerm_resource_group.resource_group.location
  address_space = [ "10.0.0.0/16" ]
}

resource "azurerm_subnet" "subnet" {
  name = var.subnet
  resource_group_name = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes = [ "10.0.0.0/24" ]
}

resource "azurerm_public_ip" "public_ip" {
  name = var.public_ip
  resource_group_name = azurerm_resource_group.resource_group.name
  location = azurerm_resource_group.resource_group.location
  allocation_method = "Static"
}

resource "azurerm_lb" "load_balancer" {
  name = "${var.load_balancer}-${var.environment}"
  resource_group_name = azurerm_resource_group.resource_group.name
  location = azurerm_resource_group.resource_group.location
  frontend_ip_configuration {
    name = "PublicIpAddress"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
  tags = {
    environment = var.environment
  }
}

resource "azurerm_lb_backend_address_pool" "lb_backend_address_pool" {
  name = "${var.load_balancer}-backend-ap"
  loadbalancer_id = azurerm_lb.load_balancer.id
}

resource "azurerm_lb_probe" "health_probe" {
  name = "${var.load_balancer}-hp"
  loadbalancer_id = azurerm_lb.load_balancer.id
  port = 80
}

resource "azurerm_lb_rule" "lb_rule" {
  name = "${var.load_balancer}-rule"
  loadbalancer_id = azurerm_lb.load_balancer.id
  protocol = "Tcp"
  frontend_port = 80
  backend_port = 80
  frontend_ip_configuration_name = "PublicIpAddress"
  idle_timeout_in_minutes = 30
  enable_floating_ip = true
  disable_outbound_snat = true
  load_distribution = "SourceIP"
  probe_id = azurerm_lb_probe.health_probe.id
}

