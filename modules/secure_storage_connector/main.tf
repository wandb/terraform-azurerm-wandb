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