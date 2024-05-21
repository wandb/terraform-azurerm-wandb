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
}

locals {
  current_time = timestamp()

  database_name = "wandb_local"

  master_username = "wandb"
  master_password = random_string.master_password.result

  master_instance_name = "${var.namespace}-${random_pet.mysql.id}-8"
}

resource "azurerm_mysql_flexible_server" "default" {
  administrator_login    = local.master_username
  administrator_password = local.master_password
  backup_retention_days        = 14
  delegated_subnet_id = var.database_subnet_id
  geo_redundant_backup_enabled = false
  location            = var.location
  name                = local.master_instance_name
  private_dns_zone_id = var.database_private_dns_zone_id
  resource_group_name = var.resource_group_name
  sku_name = var.sku_name
  version  = var.database_version
  create_mode = "PointInTimeRestore"
  source_server_id = "/subscriptions/636d899d-58b4-4d7b-9e56-7a984388b4c8/resourceGroups/wandb-qa-azure/providers/Microsoft.DBforMySQL/flexibleServers/wandb-qa-azure-internal-insect"
  point_in_time_restore_time_in_utc = local.current_time

  high_availability {
    mode = var.database_availability_mode
  }

  storage {
    auto_grow_enabled = true
    io_scaling_enabled = true
  }

  lifecycle {
    ignore_changes = [
      zone,
      high_availability.0.standby_availability_zone
    ]
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
#  name                = local.database_name
#  resource_group_name = var.resource_group_name
#  server_name         = azurerm_mysql_flexible_server.default.name
#  charset             = "utf8mb4"
#  collation           = "utf8mb4_general_ci"
}

import {
  to = azurerm_mysql_flexible_database.default
  from = "/subscriptions/636d899d-58b4-4d7b-9e56-7a984388b4c8/resourceGroups/wandb-qa-azure/providers/Microsoft.DBforMySQL/flexibleServers/wandb-qa-azure-crucial-gannet-8/databases/wandb_local"
}
