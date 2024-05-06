provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "group" {
  name     = "${var.namespace}-resources"
  location = var.location
}

resource "azurerm_user_assigned_identity" "default" {
  name                = "${var.namespace}-identity"
  location            = var.location
  resource_group_name = azurerm_resource_group.group.name
}

resource "azurerm_federated_identity_credential" "app" {
  parent_id           = azurerm_user_assigned_identity.default.id
  name                = "${var.namespace}-federated-credential"
  resource_group_name = azurerm_resource_group.group.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.oidc_issuer_url
  subject             = "system:serviceaccount:default:wandb-app"
}

module "storage" {
  depends_on = [azurerm_user_assigned_identity.default]

  source = "../storage"

  create_queue                  = false
  namespace                     = var.namespace
  resource_group_name           = azurerm_resource_group.group.name
  location                      = azurerm_resource_group.group.location
  managed_identity_principal_id = azurerm_user_assigned_identity.default.principal_id
  container_name                = var.namespace

  deletion_protection = false
}