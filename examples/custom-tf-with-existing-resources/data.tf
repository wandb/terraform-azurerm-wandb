data "azurerm_subscription" "current" {}

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

data "azurerm_kubernetes_cluster" "cluster" {
  name                = var.aks_cluster_name
  resource_group_name = var.namespace
}

data "azurerm_user_assigned_identity" "identity" {
  name                = var.identity_name
  resource_group_name = var.namespace
}
