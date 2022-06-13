locals {
    k8s_gateway_subnet_name = "${var.namespace}-k8s-subnet"
}

data "azurerm_resource_group" "wandb" {
    name  = "${var.namespace}"
}

resource "azurerm_mysql_server" "wandb" {
  name                = var.namespace
  location            = data.azurerm_resource_group.wandb.location
  resource_group_name = data.azurerm_resource_group.wandb.name

  administrator_login          = var.db_admin
  administrator_login_password = var.db_password

  sku_name   = "GP_Gen5_4"
  storage_mb = 10240
  version    = var.mysql_version

  auto_grow_enabled                 = true
  backup_retention_days             = 14
  geo_redundant_backup_enabled      = false
  infrastructure_encryption_enabled = true
  public_network_access_enabled     = false
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"

  lifecycle {
    # The DB can scale, just use whatever value it's currently scaled to
    ignore_changes = [
      storage_mb
    ]
  }
}

resource "azurerm_mysql_database" "wandb" {
  name                = "wandb"
  resource_group_name = data.azurerm_resource_group.wandb.name
  server_name         = azurerm_mysql_server.wandb.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_general_ci"
}

data "azurerm_virtual_network" "wandb" {
  resource_group_name = data.azurerm_resource_group.wandb.name
  name                = "${var.namespace}-vnet"
}

data "azurerm_subnet" "backend" {
  name                 = local.k8s_gateway_subnet_name
  virtual_network_name = data.azurerm_virtual_network.wandb.name
  resource_group_name  = data.azurerm_resource_group.wandb.name
}

resource "azurerm_private_endpoint" "wandb" {
  name                = "wandb-mysql-endpoint"
  location            = data.azurerm_resource_group.wandb.location
  resource_group_name = data.azurerm_resource_group.wandb.name
  subnet_id           = data.azurerm_subnet.backend.id

  private_service_connection {
    name                           = "wandb-mysql-connection"
    private_connection_resource_id = azurerm_mysql_server.wandb.id
    subresource_names              = ["mysqlServer"]
    is_manual_connection           = false
  }
}

# Try replacing the above block with this after bringing up the service successfully
# resource "azurerm_mysql_virtual_network_rule" "mysql_service_endpoint" {
#   name                = var.mysql_vnetRule
#   resource_group_name = data.azurerm_resource_group.wandb.name
#   server_name         = azurerm_mysql_server.wandb.name
#   subnet_id           = azurerm_subnet.subnet_aks.id
# }
