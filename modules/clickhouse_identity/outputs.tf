output "identity" {
  value       = azurerm_user_assigned_identity.clickhouse
  description = "The ClickHouse managed identity resource"
}

output "client_id" {
  value       = azurerm_user_assigned_identity.clickhouse.client_id
  description = "The client ID of the ClickHouse managed identity"
}

output "principal_id" {
  value       = azurerm_user_assigned_identity.clickhouse.principal_id
  description = "The principal ID of the ClickHouse managed identity"
}

output "tenant_id" {
  value       = azurerm_user_assigned_identity.clickhouse.tenant_id
  description = "The tenant ID of the ClickHouse managed identity"
}
