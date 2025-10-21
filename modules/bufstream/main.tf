locals {
  clean_namespace      = replace(replace(var.namespace, "wandb", ""), "cluster", "")
  no_hyphens           = replace(local.clean_namespace, "-", "")
  short_name           = substr(local.no_hyphens, 0, 15)
  storage_account_name = "${local.short_name}bufstream"
}

resource "azurerm_storage_account" "bufstream" {
  name                     = local.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  tags = var.tags
}

resource "azurerm_storage_container" "bufstream" {
  name                  = "bufstream"
  storage_account_name  = azurerm_storage_account.bufstream.name
  container_access_type = "private"
}
