variable "location" {
  type        = string
  description = "Location of the resource group"
}

variable "project" {
  type        = string
  description = "The name of the project"
}

variable "admin_username" {
  type        = string
  description = "Admin username for virtual machine"
}

variable "admin_password" {
  type        = string
  description = "Admin password for virtual machine"
  sensitive = true
}