provider "azurerm" {
  features {}
}

module "byob" {
  source                   = "../../modules/byob"
  resource_group_name      = { name = "${var.rg_name}", id = "byob" }
  location                 = var.location
  prefix                   = var.prefix
  deletion_protection      = var.deletion_protection
  create_cmk               = var.enable_encryption
  rg_name                  = var.rg_name
  purge_protection_enabled = true
  tags                     = var.tags
}

output "blob_container" {
  value = module.byob.blob_container
}

output "storage_key" {
  value     = module.byob.azure_storage_key
  sensitive = true
}
