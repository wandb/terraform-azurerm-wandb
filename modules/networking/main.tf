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
