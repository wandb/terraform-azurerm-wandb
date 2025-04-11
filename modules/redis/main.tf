resource "azurerm_redis_cache" "default" {
  name                = var.namespace
  location            = var.location
  resource_group_name = var.resource_group_name
  capacity            = var.capacity
  family              = var.family
  sku_name            = var.sku_name

  access_keys_authentication_enabled = true
  non_ssl_port_enabled = true

  tags = var.tags

  redis_configuration {
    data_persistence_authentication_method = "SAS"
  }

}
