output "account" {
  value = azurerm_storage_account.default
}

output "container" {
  value = azurerm_storage_container.default
}

output "queue" {
  value = var.create_queue ? module.queue.0.queue : null
}