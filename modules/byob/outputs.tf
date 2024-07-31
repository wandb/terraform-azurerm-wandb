output "azure_storage_key" {
  value = module.storage.account.primary_access_key
}

output "storage_key_id" {
  value = try(module.vault[0].vault_internal_keys[module.vault[0].vault_key_map.storage].id, null)
}

output "blob_container" {
  value = "${module.storage.account.name}/${module.storage.container.name}"
}

output "storage_account_name" {
  value = module.storage.account.name
}
