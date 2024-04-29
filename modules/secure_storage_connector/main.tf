provider "azurerm" {
  features {}
}

# Needed for creating federated credential
resource "azurerm_resource_group" "group" {
  name     = "${var.namespace}-resources"
  location = var.location
}

module "storage" {
  source = "../storage"

  create_queue        = false
  namespace           = var.namespace
  resource_group_name      = azurerm_resource_group.group.name
  location                 = azurerm_resource_group.group.location
  managed_identity_principal_id = var.managed_identity_principal_id
  container_name = var.namespace

  deletion_protection = var.deletion_protection
}