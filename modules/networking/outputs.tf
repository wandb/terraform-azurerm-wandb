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
  description = "The subnetwork used the frontend."
}

output "database_subnet" {
  value       = azurerm_subnet.database
  description = "The subnetwork used the database."
}

output "database_private_dns_zone" {
  value       = azurerm_private_dns_zone.database
  description = "The private DNS zone dedicated to the database."
}
