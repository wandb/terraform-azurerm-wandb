# Random string to use as master password
resource "random_string" "master_password" {
  length  = 32
  special = false
}

resource "random_pet" "mysql" {
  length = 2

  keepers = {
    version = var.database_version
  }

  lifecycle {
    # The MySQL server name (${namespace}-${random_pet.mysql.id}) must stay stable
    # for the life of the install; version upgrades are applied in place by
    # azurerm_mysql_flexible_server. Ignoring the whole keepers map means a legacy
    # keeper already in state (e.g. {version = "5.7"}) never forces a rebuild, and
    # future database_version changes never regenerate the name.
    #
    # IMPORTANT: this must stay. Removing it would make every existing install's
    # random_pet regenerate to match config, recreating the server. To rebuild a
    # server intentionally, run:
    #   terraform apply -replace='module.wandb.module.database.random_pet.mysql'
    ignore_changes = [keepers]
  }
}

locals {
  database_name = "wandb_local"

  master_username = "wandb"
  master_password = random_string.master_password.result

  master_instance_name = "${var.namespace}-${random_pet.mysql.id}"

  default_flags = {
    "binlog_row_image"           = "minimal"
    "max_binlog_size"            = "1073741824"
    "long_query_time"            = "4"
    "max_execution_time"         = "600000"
    "slow_query_log"             = "on"
    "sort_buffer_size"           = tostring(var.sort_buffer_size)
  }
  database_flags = merge(local.default_flags, var.database_flags)
}

resource "azurerm_mysql_flexible_server" "default" {
  name                = local.master_instance_name
  location            = var.location
  resource_group_name = var.resource_group_name

  administrator_login    = local.master_username
  administrator_password = local.master_password

  sku_name = var.sku_name
  version  = var.database_version

  delegated_subnet_id = var.database_subnet_id
  private_dns_zone_id = var.database_private_dns_zone_id

  backup_retention_days        = 14
  geo_redundant_backup_enabled = false

  high_availability {
    mode = var.database_availability_mode
  }

  storage {
    auto_grow_enabled = true
  }

  lifecycle {
    ignore_changes = [
      zone,
      high_availability.0.standby_availability_zone
    ]
  }

  dynamic "identity" {
    for_each = var.database_key_id != null ? [1] : []
    content {
      type         = "UserAssigned"
      identity_ids = [var.identity_ids]
    }
  }
  dynamic "customer_managed_key" {
    for_each = var.database_key_id != null ? [1] : []
    content {
      primary_user_assigned_identity_id = var.identity_ids
      key_vault_key_id                  = var.database_key_id
    }
  }
  tags = var.tags
}

resource "azurerm_management_lock" "default" {
  count      = var.deletion_protection ? 1 : 0
  name       = "${var.namespace}-db"
  scope      = azurerm_mysql_flexible_server.default.id
  lock_level = "CanNotDelete"
  notes      = "Deletion protection is enabled on the database."
}

resource "azurerm_mysql_flexible_database" "default" {
  name                = local.database_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.default.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_general_ci"
}

resource "azurerm_mysql_flexible_server_configuration" "default" {
  for_each = local.database_flags

  name                = each.key
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.default.name
  value               = each.value
}
