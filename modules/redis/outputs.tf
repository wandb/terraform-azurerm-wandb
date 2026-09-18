output "instance" {
  value = {
    hostname           = azurerm_managed_redis.default.hostname
    port               = azurerm_managed_redis.default.default_database[0].port
    primary_access_key = azurerm_managed_redis.default.default_database[0].primary_access_key
  }
  sensitive = true
}
