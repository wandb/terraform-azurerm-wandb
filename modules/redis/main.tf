resource "azurerm_redis_cache" "default" {
  name                = var.namespace
  location            = var.location
  resource_group_name = var.resource_group_name
  capacity            = var.capacity
  family              = var.family
  sku_name            = var.sku_name

  enable_non_ssl_port = true

  redis_configuration {
  }

  tags = {
    "customer-ns" = var.namespace,
    "env"         = "managed-install"
  }
}
