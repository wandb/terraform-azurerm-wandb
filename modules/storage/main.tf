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

  dynamic "identity" {
    for_each = var.dynamic_create_cmk == true ? [1] : []
    content {
      type         = "UserAssigned"
      identity_ids = [var.identity_ids]
    }
  }
  dynamic "customer_managed_key" {
    for_each = var.dynamic_create_cmk == true ? [1] : []
    content {
      user_assigned_identity_id = var.identity_ids
      key_vault_key_id          = var.wb_managed_key_id
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

module "queue" {
  count = var.create_queue ? 1 : 0

  source    = "./queue"
  namespace = var.namespace

  resource_group_name = var.resource_group_name
  location            = var.location

  storage_account   = azurerm_storage_account.default
  storage_container = azurerm_storage_container.default
}
