output "azure_storage_key" {
  value = module.storage.account.primary_access_key
}

output "blob_container" {
  value = "${module.storage.account.name}/${module.storage.container.name}"
}