data "azurerm_client_config" "current" {
}

data "azurerm_resource_group" "group" {
  name = var.resource_group_name
}

module "service_accounts" {
  source = "./service_accounts"
}

locals {
  k8s_sa_map = merge(
    {
      app = "wandb-app"
    },
    module.service_accounts.k8s_sa_map
  )
}

resource "azurerm_user_assigned_identity" "default" {
  name                = "${var.namespace}-identity"
  location            = data.azurerm_resource_group.group.location
  resource_group_name = data.azurerm_resource_group.group.name
}

resource "azurerm_federated_identity_credential" "sa_map" {
  for_each            = local.k8s_sa_map
  parent_id           = azurerm_user_assigned_identity.default.id
  name                = "${var.namespace}-federated-credential-${each.value}"
  resource_group_name = data.azurerm_resource_group.group.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.oidc_issuer_url
  subject             = "system:serviceaccount:default:${each.value}"
}

module "storage" {
  depends_on = [azurerm_user_assigned_identity.default]

  source = "../storage"

  create_queue        = false
  namespace           = var.namespace
  location            = data.azurerm_resource_group.group.location
  resource_group_name = data.azurerm_resource_group.group.name
  blob_container_name = var.namespace

  deletion_protection = var.deletion_protection
}

resource "azurerm_role_assignment" "account" {
  depends_on = [module.storage]

  scope                = module.storage.account.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = azurerm_user_assigned_identity.default.principal_id
}

resource "azurerm_role_assignment" "container" {
  depends_on = [module.storage]

  scope                = module.storage.account.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azurerm_user_assigned_identity.default.principal_id
}
