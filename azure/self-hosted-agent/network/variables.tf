variable "location" {
  type = string
  description = "Location of the resources"
}

variable "virtual_network_name" {
  type = string
  description = "The virtual network base name"
}

variable "resource_group" {
  type = string
  description = "The resource group for vnet deployment"
}

variable "nsg_name" {
  type = string
  description = "NSG Name"
}

variable "public_ip_name" {
  type = string
  description = "Public IP Address name"
}

variable "nic_name" {
  type = string
  description = "Network Interface Card name"
}