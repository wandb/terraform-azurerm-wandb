data "azurerm_virtual_network" "network" {
  name                = var.vpc_name
  resource_group_name = var.namespace
}

data "azurerm_subnet" "public" {
  name                 = var.public_subnet
  virtual_network_name = var.vpc_name
  resource_group_name  = var.namespace
}

data "azurerm_subnet" "private" {
  name                 = var.private_subnet
  virtual_network_name = var.vpc_name
  resource_group_name  = var.namespace
}

data "azurerm_resource_group" "group" {
  name = var.namespace
}
data "azurerm_subscription" "current" {}