locals {
  postfix             = "clickhouse"
  truncated_namespace = substr(replace(var.namespace, "-", ""), 0, 24 - length(local.postfix))
}

resource "azurerm_storage_account" "clickhouse" {
  name                             = "${local.truncated_namespace}${local.postfix}"
  resource_group_name              = var.resource_group_name
  location                         = var.location
  account_tier                     = "Standard"
  account_replication_type         = var.replication_type
  min_tls_version                  = "TLS1_2"
  cross_tenant_replication_enabled = false

  blob_properties {
    cors_rule {
      allowed_headers    = ["*"]
      allowed_methods    = ["GET", "HEAD", "PUT", "DELETE"]
      allowed_origins    = ["*"]
      exposed_headers    = ["*"]
      max_age_in_seconds = 3600
    }
  }

  tags = var.tags
}

resource "azurerm_storage_container" "clickhouse" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.clickhouse.name
  container_access_type = "private"
}

resource "azurerm_management_lock" "clickhouse" {
  count      = var.deletion_protection ? 1 : 0
  name       = "${var.namespace}-clickhouse-container"
  scope      = azurerm_storage_account.clickhouse.id
  lock_level = "CanNotDelete"
  notes      = "Deletion protection is enabled on the ClickHouse storage container."
}
