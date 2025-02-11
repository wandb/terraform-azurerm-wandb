output "instance" {
  value = azurerm_redis_cache.default
}

output "hostname" {
  value = azurerm_redis_cache.default.hostname
}

output "port" {
  value = azurerm_redis_cache.default.port
}

output "primary_access_keys" {
  value = azurerm_redis_cache.default.primary_access_key
}