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

  service_endpoints = [
    "Microsoft.Sql",
    "Microsoft.Storage",
    "Microsoft.KeyVault"
  ]
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

resource "azurerm_network_security_group" "allowlist_nsg" {
  count               = length(var.allowed_ip_ranges) > 0 ? 1 : 0
  name                = "${var.namespace}-allowlist-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  dynamic "security_rule" {
    for_each = var.allowed_ip_ranges
    content {
      name                       = "${security_rule.key}"
      priority                   = "${security_rule.value.priority}"
      direction                  = "Inbound"
      access                     = "${security_rule.value.access}"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "${security_rule.value.source_address_prefix}"
      destination_address_prefix = "*"
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "public_association" {
  count = length(var.allowed_ip_ranges) > 0 ? 1 : 0
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.allowlist_nsg[count.index].id
}