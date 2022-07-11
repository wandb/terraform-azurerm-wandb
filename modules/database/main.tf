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
  database_name = "wandb_local"

  master_username = "wandb"
  master_password = random_string.master_password.result

  master_instance_name = "${var.namespace}-${random_pet.mysql.id}"
}

resource "azurerm_mysql_server" "default" {
  name                = var.database_name
  location            = var.location
  resource_group_name = var.resource_group_name

  administrator_login          = var.master_username
  administrator_login_password = var.master_password

  sku_name = var.sku_name
  version  = var.database_version

  storage_mb        = 5120
  auto_grow_enabled = true

  backup_retention_days             = 14
  geo_redundant_backup_enabled      = false
  infrastructure_encryption_enabled = true
  public_network_access_enabled     = false
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"

  lifecycle {
    ignore_changes = [storage_mb]
  }
}

resource "azurerm_mysql_database" "default" {
  name                = "wandb"
  resource_group_name = var.azurerm_resource_group
  server_name         = azurerm_mysql_server.default.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_general_ci"
}