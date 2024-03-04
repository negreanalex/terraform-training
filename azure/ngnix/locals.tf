locals {
  dev = {
    environment          = "dev"
    size                 = "Standard_B1s"
    storage_account_type = "Standard_LRS"
    os_disk_name         = "disk-os-linux-dev"
  }
  prod = {
    environment          = "prod"
    size                 = "Standard_D2s_v3"
    storage_account_type = "Standard_GRS"
    os_disk_name         = "disk-os-linux-prod"
  }
}