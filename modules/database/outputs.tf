locals {
  output_username = azurerm_mysql_flexible_server.default.administrator_login
  output_password = azurerm_mysql_flexible_server.default.administrator_password
  output_fqdn     = "${azurerm_mysql_flexible_server.default.fqdn}:5432"
  # output_connection_name = replace(google_sql_database_instance.default.connection_name, ":", ".")
}

output "database_name" {
  value = local.database_name
}

output "username" {
  value = local.master_username
}

output "password" {
  value     = local.master_password
  sensitive = true
}

output "address" {
  value       = "${azurerm_mysql_flexible_server.default.fqdn}:5432"
  description = "The address of the MySQL database."
}

output "server" {
  value = azurerm_mysql_flexible_server.default

  description = "The MySQL server."
}
