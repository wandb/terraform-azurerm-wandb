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
}

resource "azurerm_storage_container" "default" {
  name                  = "wandb"
  storage_account_name  = azurerm_storage_account.default.name
  container_access_type = "private"
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