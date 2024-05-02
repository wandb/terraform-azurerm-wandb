provider "azurerm" {
  features {}
}

# Needed for creating federated credential
resource "azurerm_resource_group" "group" {
  name     = "${var.namespace}-resources"
  location = var.location
}

resource "azurerm_user_assigned_identity" "default" {
  name                = "${var.namespace}-identity"
  location            = var.location
  resource_group_name = azurerm_resource_group.group.name
}

module "storage" {
  source = "../storage"

  create_queue                  = false
  namespace                     = var.namespace
  resource_group_name           = azurerm_resource_group.group.name
  location                      = azurerm_resource_group.group.location
  managed_identity_principal_id = azurerm_user_assigned_identity.default.principal_id
  container_name                = var.namespace

  deletion_protection = var.deletion_protection
}