data "azurerm_client_config" "current" {
}

data "azurerm_resource_group" "group" {
  name = var.resource_group_name
}

locals {
  sa_map = {
    "wandb-app"                     = "wandb-app",
    "wandb-api"                     = "wandb-api",
    "wandb-console"                 = "wandb-console",
    "wandb-executor"                = "wandb-executor",
    "wandb-flat-run-fields-updater" = "wandb-flat-run-fields-updater",
    "wandb-parquet"                 = "wandb-parquet",
    "wandb-filestream"              = "wandb-filestream",
    "wandb-filemeta"                = "wandb-filemeta",
    "wandb-glue"                    = "wandb-glue",
    "wandb-weave"                   = "wandb-weave",
    "wandb-weave-trace"             = "wandb-weave-trace",
    "wandb-settings-migration-job"  = "wandb-settings-migration-job",
    "wandb-bufstream"               = "bufstream-service-account"
  }
}

resource "azurerm_user_assigned_identity" "default" {
  name                = "${var.namespace}-identity"
  location            = data.azurerm_resource_group.group.location
  resource_group_name = data.azurerm_resource_group.group.name
}

resource "azurerm_federated_identity_credential" "sa_map" {
  for_each            = local.sa_map
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
