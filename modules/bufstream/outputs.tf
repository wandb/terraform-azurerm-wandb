output "storage_account" {
  description = "Bufstream storage account object"
  value       = azurerm_storage_account.bufstream
}

output "storage_account_name" {
  description = "Bufstream storage account name"
  value       = azurerm_storage_account.bufstream.name
}

output "container" {
  description = "Bufstream container object"
  value       = azurerm_storage_container.bufstream
}

output "container_name" {
  description = "Bufstream container name"
  value       = azurerm_storage_container.bufstream.name
}

output "storage_account_key" {
  description = "Bufstream storage account primary access key"
  value       = nonsensitive(azurerm_storage_account.bufstream.primary_access_key)
}
