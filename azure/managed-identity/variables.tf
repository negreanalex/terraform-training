variable "environment" {
  type = string
  default = "Test"
}

variable "rg_name" {
  type = string
}

variable "location" {
  type = string
}

variable "kv_name" {
  type = string
}

variable "kv_sku_name" {
  type = string
}

variable "kv_secret_name" {
  type = string
}

variable "nsg" {
  type = string
}