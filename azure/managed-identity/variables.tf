variable "environment" {
  type = string
  default = "Test"
}

variable "rg_name" {
  type = string
  default = "rg-test-003"
}

variable "location" {
  type = string
  default = "northeurope"
}

variable "kv_name" {
  type = string
  default = "kv"
}

variable "kv_sku_name" {
  type = string
  default = "standard"
}

variable "kv_secret_name" {
  type = string
  default = "vmpass"
}

variable "nsg" {
  type = string
  default = "nsg-001"
}