provider "azurerm" {
  features {}
}

module "byob" {
  source                       = "../../modules/byob"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  prefix                       = var.prefix
  deletion_protection          = var.deletion_protection
  create_cmk                   = var.create_cmk
  client_id                    = var.client_id
  tenant_id                    = var.tenant_id
  tags                         = var.tags
  disable_storage_vault_key_id = var.disable_storage_vault_key_id
}

output "blob_container" {
  value = module.byob.blob_container
}

output "storage_key" {
  value     = module.byob.azure_storage_key
  sensitive = true
}

output "storage_vault_key_id" {
  value = module.byob.vault_key_id
}

output "command_to_get_storage_key" {
  value = "az storage account keys list --account-name ${module.byob.storage_account_name} --resource-group ${module.byob.resource_group_name.name} --query '[0].value' -o tsv"
}
