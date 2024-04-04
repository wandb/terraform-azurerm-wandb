output "storage_account_name" {
  value = azurerm_storage_account.account.name
}

output "container_name" {
  value = azurerm_storage_container.container.name
}

#output "key_vault_name" {
#  value = azurerm_key_vault.example.name
#}
#
#output "key_vault_key_name" {
#  value = azurerm_key_vault_key.example.name
#}

# FROM BYOB MODULE
#output "azure_storage_key" {
#  value = module.storage.account.primary_access_key
#}
#
#output "blob_container" {
#  value = "${module.storage.account.name}/${module.storage.container.name}"
#}