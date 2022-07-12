resource "azurerm_private_dns_zone" "database" {
  name                = "${var.namespace}.mysql.database.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "database" {
  name                  = "${var.namespace}-database"
  private_dns_zone_name = azurerm_private_dns_zone.database.name
  resource_group_name   = var.resource_group_name
  virtual_network_id    = azurerm_virtual_network.default.id
}

resource "azurerm_subnet" "database" {
  name                 = "${var.namespace}-database"
  resource_group_name  = var.resource_group_name
  address_prefixes     = [var.network_database_subnet_cidr]
  virtual_network_name = azurerm_virtual_network.default.name

  delegation {
    name = "flexibleServers"
    service_delegation {
      name    = "Microsoft.DBforMySQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.database]
}
