resource "azurerm_managed_redis" "default" {
  name                = var.namespace
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = var.sku_name

  high_availability_enabled = true
  public_network_access     = var.private_endpoint_enabled ? "Disabled" : "Enabled"

  tags = var.tags

  default_database {
    # Current W&B images consume a static Redis password and standard Redis
    # semantics. Keep access-key authentication and NoCluster until Entra ID
    # token refresh and clustered Redis are supported across all components.
    # Traffic remains encrypted in transit through the TLS-only endpoint.
    access_keys_authentication_enabled = true
    client_protocol                    = "Encrypted"
    clustering_policy                  = "NoCluster"
  }
}

resource "azurerm_private_endpoint" "default" {
  count = var.private_endpoint_enabled ? 1 : 0

  name                = "${var.namespace}-redis"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.namespace}-redis"
    private_connection_resource_id = azurerm_managed_redis.default.id
    # Azure Managed Redis retains the redisEnterprise private-link subresource
    # name even though the Azure service is branded Azure Managed Redis.
    subresource_names    = ["redisEnterprise"]
    is_manual_connection = false
  }

  private_dns_zone_group {
    name                 = "redis"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }

  tags = var.tags
}
