output "storage_account" {
  value       = azurerm_storage_account.clickhouse
  description = "The ClickHouse storage account resource"
}

output "storage_container" {
  value       = azurerm_storage_container.clickhouse
  description = "The ClickHouse storage container resource"
}

output "storage_account_name" {
  value       = azurerm_storage_account.clickhouse.name
  description = "The name of the ClickHouse storage account"
}

output "container_name" {
  value       = azurerm_storage_container.clickhouse.name
  description = "The name of the ClickHouse storage container"
}

output "primary_access_key" {
  value       = azurerm_storage_account.clickhouse.primary_access_key
  sensitive   = true
  description = "The primary access key for the ClickHouse storage account"
}

output "primary_blob_endpoint" {
  value       = azurerm_storage_account.clickhouse.primary_blob_endpoint
  description = "The primary blob endpoint for the ClickHouse storage account"
}
