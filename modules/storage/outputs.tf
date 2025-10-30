output "account" {
  value = azurerm_storage_account.default
}

output "container" {
  value = azurerm_storage_container.default
}

output "queue" {
  value = var.create_queue ? module.queue.0.queue : null
}

# TODO(aravind): Remove - for testing bufstream
output "primary_access_key" {
  value       = azurerm_storage_account.default.primary_access_key
  sensitive   = true
  description = "Primary access key for storage account"
}