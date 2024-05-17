locals {
  output_username = azurerm_mysql_flexible_server.default.administrator_login
  output_database = azurerm_mysql_flexible_database.default.name
  output_password = azurerm_mysql_flexible_server.default.administrator_password
  output_fqdn     = azurerm_mysql_flexible_server.default.fqdn
}

output "database_name" {
  value = local.output_database
}

output "username" {
  value = local.output_username
}

output "password" {
  value     = local.output_password
  sensitive = true
}

output "address" {
  value       = local.output_fqdn
  description = "The address of the MySQL database."
}

output "server" {
  value = azurerm_mysql_flexible_server.default

  description = "The MySQL server."
}

output "connection_string" {
  value = "${azurerm_mysql_flexible_server.default.administrator_login}:${azurerm_mysql_flexible_server.default.administrator_password}@${azurerm_mysql_flexible_server.default.fqdn}/${azurerm_mysql_flexible_database.default.name}"
}
