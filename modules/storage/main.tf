resource "azurerm_storage_account" "default" {
  name                     = replace("${var.namespace}-storage", "-", "")
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "ZRS"
  min_tls_version          = "TLS1_2"

  blob_properties {
    cors_rule {
      allowed_headers    = ["*"]
      allowed_methods    = ["GET", "HEAD", "PUT"]
      allowed_origins    = ["*"]
      exposed_headers    = ["*"]
      max_age_in_seconds = 3600
    }
  }

  queue_properties {
    logging {
      delete                = true
      read                  = true
      write                 = true
      version               = "1.0"
      retention_policy_days = 10
    }
  }

  tags = var.tags
}

resource "azurerm_storage_container" "default" {
  name                  = var.blob_container_name
  storage_account_name  = azurerm_storage_account.default.name
  container_access_type = "private"
}

resource "azurerm_management_lock" "default" {
  count      = var.deletion_protection ? 1 : 0
  name       = "${var.namespace}-container"
  scope      = azurerm_storage_account.default.id
  lock_level = "CanNotDelete"
  notes      = "Deletion protection is enabled on the storage container."
}

# Setting RBAC for the managed identity is optional. If not using, it's because the container is being accessed with
# the storage account key.
resource "azurerm_role_assignment" "account" {
  count = var.managed_identity_principal_id != "" ? 1 : 0

  scope                = azurerm_storage_account.default.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = var.managed_identity_principal_id
}
resource "azurerm_role_assignment" "container" {
  count = var.managed_identity_principal_id != "" ? 1 : 0

  scope                = azurerm_storage_account.default.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = var.managed_identity_principal_id
}

module "queue" {
  count = var.create_queue ? 1 : 0

  source    = "./queue"
  namespace = var.namespace

  resource_group_name = var.resource_group_name
  location            = var.location

  storage_account   = azurerm_storage_account.default
  storage_container = azurerm_storage_container.default
}
