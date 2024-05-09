provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

// if var.resource_group_name is provided, this tf module will add the storage and managed identity to an already
// existing resource group
// if var.resource_group_name is NOT provided, this tf module will create and manage a new resource group, and add
// the other resources to the new resource group
data "azurerm_resource_group" "current" {
  count = var.resource_group_name != "" ? 1 : 0
  name  = var.resource_group_name
}
resource "azurerm_resource_group" "new" {
  count    = var.resource_group_name == "" ? 1 : 0
  name     = "${var.namespace}-resources"
  location = var.location
}

resource "azurerm_user_assigned_identity" "default" {
  name                = "${var.namespace}-identity"
  location            = var.resource_group_name != "" ? data.azurerm_resource_group.current[0].location : var.location
  resource_group_name = var.resource_group_name != "" ? var.resource_group_name : azurerm_resource_group.new[0].name
}

resource "azurerm_federated_identity_credential" "app" {
  parent_id           = azurerm_user_assigned_identity.default.id
  name                = "${var.namespace}-federated-credential"
  resource_group_name = var.resource_group_name != "" ? var.resource_group_name : azurerm_resource_group.new[0].name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.oidc_issuer_url
  subject             = "system:serviceaccount:default:wandb-app"
}

module "storage" {
  depends_on = [azurerm_user_assigned_identity.default]

  source = "../storage"

  create_queue                  = false
  namespace                     = var.namespace
  resource_group_name           = var.resource_group_name != "" ? var.resource_group_name : azurerm_resource_group.new[0].name
  location                      = var.resource_group_name != "" ? data.azurerm_resource_group.current[0].location : var.location
  managed_identity_principal_id = azurerm_user_assigned_identity.default.principal_id
  blob_container_name           = var.namespace

  deletion_protection = var.deletion_protection
}