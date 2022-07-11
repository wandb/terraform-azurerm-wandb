
resource "azurerm_resource_group" "default" {
  name     = var.namespace
  location = var.location
}

module "database" {
  source              = "./modules/database"
  namespace           = var.namespace
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location

  database_version = var.database_version
}