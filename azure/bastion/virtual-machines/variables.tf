variable "resource_group_name" {
  type = string
  description = "The resource group for vnet deployment"
}

variable "location" {
  type = string
  description = "Location of the resources"
}

variable "virtual_machine_name" {
  type = string
  description = "Virtual Machine Name"
}

variable "size" {
  type = string
  description = "Size of the virtual machine"
}

variable "admin_username" {
  type = string
  description = "Admin username for virtual machine"
}

variable "admin_password" {
  type = string
  sensitive = true
  description = "Admin password for virtual machine"
}

variable "nic_id" {
  type = string
  description = "Network interface card ID"
}

variable "os_disk_name" {
  type = string
  description = "Operating System Disk name"
}

variable "storage_account_type" {
  type = string
  description = "Type of the storage account"
}

variable "environment" {
  type = string
  description = "Environment type of the VM"
}