provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

data "azurerm_resource_group" "group" {
  name = var.resource_group_name
}

resource "azurerm_user_assigned_identity" "default" {
  name                = "${var.namespace}-identity"
  location            = data.azurerm_resource_group.group.location
  resource_group_name = data.azurerm_resource_group.group.name
}

resource "azurerm_federated_identity_credential" "app" {
  parent_id           = azurerm_user_assigned_identity.default.id
  name                = "${var.namespace}-federated-credential"
  resource_group_name = data.azurerm_resource_group.group.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.oidc_issuer_url
  subject             = "system:serviceaccount:default:wandb-app"
}

module "storage" {
  depends_on = [azurerm_user_assigned_identity.default]

  source = "../storage"

  create_queue                  = false
  namespace                     = var.namespace
  location                      = data.azurerm_resource_group.group.location
  resource_group_name           = data.azurerm_resource_group.group.name
  managed_identity_principal_id = azurerm_user_assigned_identity.default.principal_id
  blob_container_name           = var.namespace

  deletion_protection = var.deletion_protection
}