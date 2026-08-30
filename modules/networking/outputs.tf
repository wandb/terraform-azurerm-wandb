output "network" {
  value       = azurerm_virtual_network.default
  description = "The virtual network used for all resources"
}

output "private_subnet" {
  value       = azurerm_subnet.private
  description = "The subnetwork used for W&B"
}

output "kubernetes_subnet" {
  value       = azurerm_subnet.kubernetes
  description = "The subnetwork used for W&B"
}

output "public_subnet" {
  value       = azurerm_subnet.public
  description = "The subnetwork used the frontend."
}

output "redis_subnet" {
  value       = azurerm_subnet.redis
  description = "The subnet used for the Azure Managed Redis private endpoint."
}

output "redis_private_dns_zone_id" {
  value       = try(azurerm_private_dns_zone.redis[0].id, null)
  description = "The ID of the Azure Managed Redis private DNS zone."
}

output "key_vault_subnet_id" {
  value       = try(azurerm_subnet.key_vault[0].id, null)
  description = "The subnet ID used for the Key Vault private endpoint."
}

output "key_vault_private_dns_zone_id" {
  value       = try(azurerm_private_dns_zone.key_vault[0].id, null)
  description = "The ID of the Key Vault private DNS zone."
}

output "database_subnet" {
  value       = azurerm_subnet.database
  description = "The subnetwork used the database."
}

output "database_private_dns_zone" {
  value       = azurerm_private_dns_zone.database
  description = "The private DNS zone dedicated to the database."
}
