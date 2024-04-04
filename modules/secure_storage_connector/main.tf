provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "group" {
  name     = "${var.namespace}-resources"
  location = var.location
}

resource "azurerm_storage_account" "account" {
  name                     = "${var.namespace}storageaccount"
  resource_group_name      = azurerm_resource_group.group.name
  location                 = azurerm_resource_group.group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = "true"
}

resource "azurerm_storage_container" "container" {
  name                  = "${var.namespace}-container"
  storage_account_name  = azurerm_storage_account.account.name
  container_access_type = "private"
}

resource "azurerm_role_assignment" "principal" {
  scope                = azurerm_storage_account.account.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = var.azure_principal_id
}

resource "azurerm_role_assignment" "principal2" {
  scope                = azurerm_storage_account.account.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = var.azure_principal_id
}

#resource "azurerm_key_vault" "example" {
#  name                        = "${var.namespace}-keyvault"
#  location                    = azurerm_resource_group.example.location
#  resource_group_name         = azurerm_resource_group.example.name
#  tenant_id                   = data.azurerm_client_config.current.tenant_id
#  sku_name                    = "standard"
#
#  soft_delete_enabled         = true
#  purge_protection_enabled    = var.deletion_protection
#}
#
#resource "azurerm_key_vault_key" "example" {
#  name         = "${var.namespace}-key"
#  key_vault_id = azurerm_key_vault.example.id
#  key_type     = "RSA"
#  key_size     = 2048
#  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
#
#  depends_on = [azurerm_key_vault.example]
#}

#resource "azurerm_role_assignment" "keyvault" {
#  scope                = azurerm_key_vault.example.id
#  role_definition_name = "Key Vault Crypto Officer"
#  principal_id         = var.azure_principal_id
#}

#module "storage" {
#  source = "../storage"
#
#  create_queue        = false
#  namespace           = var.prefix
#  resource_group_name = var.resource_group_name
#  location            = var.location
#
#  deletion_protection = var.deletion_protection
#}
