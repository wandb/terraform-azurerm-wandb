provider "azurerm" {
  features {}
}

module "byob" {
  source              = "../../modules/byob"
  resource_group_name = var.resource_group_name
  location            = var.location
  prefix              = var.prefix
  deletion_protection = var.deletion_protection
}


output "blob_container" {
  value = module.byob.blob_container
}

output "storage_key" {
  value     = module.byob.azure_storage_key
  sensitive = true
}
