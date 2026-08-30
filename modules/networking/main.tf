resource "azurerm_virtual_network" "default" {
  name                = "${var.namespace}-vpc"
  location            = var.location
  resource_group_name = var.resource_group_name

  address_space = [var.network_cidr]

  tags = var.tags
}

resource "azurerm_subnet" "private" {
  name                                          = "${var.namespace}-private"
  resource_group_name                           = var.resource_group_name
  address_prefixes                              = [var.network_private_subnet_cidr]
  virtual_network_name                          = azurerm_virtual_network.default.name
  private_link_service_network_policies_enabled = false
  private_endpoint_network_policies             = "Enabled"

  service_endpoints = concat(
    ["Microsoft.Sql", "Microsoft.KeyVault"],
    var.private_link ? ["Microsoft.Storage.Global"] : ["Microsoft.Storage"]
  )
}

resource "azurerm_subnet" "kubernetes" {
  name                                          = "${var.namespace}-kubernetes"
  resource_group_name                           = var.resource_group_name
  address_prefixes                              = [var.network_kubernetes_subnet_cidr]
  virtual_network_name                          = azurerm_virtual_network.default.name
  private_link_service_network_policies_enabled = false
  private_endpoint_network_policies             = "Enabled"

  service_endpoints = concat(
    ["Microsoft.Sql", "Microsoft.KeyVault"],
    var.private_link ? ["Microsoft.Storage.Global"] : ["Microsoft.Storage"]
  )
}

resource "azurerm_subnet" "public" {
  name                 = "${var.namespace}-public"
  resource_group_name  = var.resource_group_name
  address_prefixes     = [var.network_public_subnet_cidr]
  virtual_network_name = azurerm_virtual_network.default.name

  private_endpoint_network_policies = "Enabled"
}

resource "azurerm_subnet" "redis" {
  name                 = "${var.namespace}-redis"
  resource_group_name  = var.resource_group_name
  address_prefixes     = [var.network_redis_subnet_cidr]
  virtual_network_name = azurerm_virtual_network.default.name

  private_endpoint_network_policies = var.create_redis_private_endpoint ? "Disabled" : "Enabled"
}

# Created only for private Redis mode. The normal Managed Redis hostname is
# retained and resolves to the endpoint IP through this private DNS zone.
resource "azurerm_private_dns_zone" "redis" {
  count = var.create_redis_private_endpoint ? 1 : 0

  name                = "privatelink.redis.azure.net"
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "redis" {
  count = var.create_redis_private_endpoint ? 1 : 0

  name                  = "${var.namespace}-redis"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.redis[0].name
  virtual_network_id    = azurerm_virtual_network.default.id

  tags = var.tags
}

resource "azurerm_subnet" "key_vault" {
  count = var.create_key_vault_private_endpoint ? 1 : 0

  name                 = "${var.namespace}-key-vault"
  resource_group_name  = var.resource_group_name
  address_prefixes     = [var.network_key_vault_subnet_cidr]
  virtual_network_name = azurerm_virtual_network.default.name

  private_endpoint_network_policies = "Disabled"
}

# Key Vault private networking is fully conditional so public mode does not
# consume a subnet or create private DNS resources.
resource "azurerm_private_dns_zone" "key_vault" {
  count = var.create_key_vault_private_endpoint ? 1 : 0

  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "key_vault" {
  count = var.create_key_vault_private_endpoint ? 1 : 0

  name                  = "${var.namespace}-key-vault"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault[0].name
  virtual_network_id    = azurerm_virtual_network.default.id

  tags = var.tags
}

resource "azurerm_network_security_group" "default" {
  count               = length(var.allowed_ip_ranges) > 0 ? 1 : 0
  name                = "${var.namespace}-allowlist-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}


resource "azurerm_network_security_rule" "allow_cidr" {
  count                       = length(var.allowed_ip_ranges) > 0 ? length(var.allowed_ip_ranges) : 0
  name                        = "allowRule-${count.index}"
  priority                    = 100 + "${count.index}"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefixes     = [var.allowed_ip_ranges[count.index]]
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.default.0.name
  depends_on                  = [azurerm_network_security_group.default]
}



resource "azurerm_network_security_rule" "default" {
  count                       = length(var.allowed_ip_ranges) > 0 ? 1 : 0
  name                        = "defaultAppGatewayV2SkuRule"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "65200-65535"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.default.0.name
}



resource "azurerm_subnet_network_security_group_association" "public" {
  count                     = length(var.allowed_ip_ranges) > 0 ? 1 : 0
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.default.0.id
  depends_on                = [azurerm_network_security_rule.default]
}
