resource "azurerm_virtual_network" "default" {
  name                = "${var.namespace}-vpc"
  location            = var.location
  resource_group_name = var.resource_group_name

  address_space = [var.network_cidr]

  tags = var.tags
}

resource "azurerm_subnet" "private" {
  name                 = "${var.namespace}-private"
  resource_group_name  = var.resource_group_name
  address_prefixes     = [var.network_private_subnet_cidr]
  virtual_network_name = azurerm_virtual_network.default.name
  # TODO(jhr): might need policies enabled for clickhouse private link
  private_link_service_network_policies_enabled = var.private_link ? false : true

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
}

resource "azurerm_subnet" "redis" {
  name                 = "${var.namespace}-redis"
  resource_group_name  = var.resource_group_name
  address_prefixes     = [var.network_redis_subnet_cidr]
  virtual_network_name = azurerm_virtual_network.default.name
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
  priority                    = 120
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



resource "azurerm_private_endpoint" "clickhouse" {
  count               = var.clickhouse_endpoint_service_id != "" ? 1 : 0

  name                = "${var.namespace}-clickhouse-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = azurerm_subnet.private.id
  custom_network_interface_name = "${var.namespace}-clickhouse-nic"

  private_service_connection {
    name                              = "${var.namespace}-clickhouse-pl"
    private_connection_resource_alias = var.clickhouse_endpoint_service_id
    is_manual_connection              = true
    request_message                   = "ClickHouse Private Link"
  }
}

resource "azurerm_private_dns_zone" "clickhouse_cloud_private_link_zone" {
  name                = "${var.clickhouse_service_location}.privatelink.azure.clickhouse.cloud"
  resource_group_name = var.resource_group_name
}

data "azurerm_network_interface" "clickhouse_nic" {
  resource_group_name = var.resource_group_name
  name                = azurerm_private_endpoint.clickhouse[0].network_interface[0].name
}

resource "azurerm_private_dns_a_record" "clickhouse_wildcard" {
  name                = "*"
  zone_name           = azurerm_private_dns_zone.clickhouse_cloud_private_link_zone.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [data.azurerm_network_interface.clickhouse_nic.private_ip_address]
}

resource "azurerm_private_dns_zone_virtual_network_link" "clickhouse_network" {
  name                  = "network-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.clickhouse_cloud_private_link_zone.name
  virtual_network_id    = azurerm_virtual_network.default.id
}
