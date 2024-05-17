
output "database_name" {
  value = azurerm_mysql_flexible_database.default.name
}

output "username" {
  value = azurerm_mysql_flexible_server.default.administrator_login
}

output "password" {
  value     = azurerm_mysql_flexible_server.default.administrator_password
  sensitive = true
}

output "address" {
  value       = azurerm_mysql_flexible_server.default.fqdn
  description = "The address of the MySQL database."
}

output "server" {
  value = azurerm_mysql_flexible_server.default

  description = "The MySQL server."
}

output "connection_string" {
  value = "${azurerm_mysql_flexible_server.default.administrator_login}:${azurerm_mysql_flexible_server.default.administrator_password}@${azurerm_mysql_flexible_server.default.fqdn}/${azurerm_mysql_flexible_database.default.name}"
}
