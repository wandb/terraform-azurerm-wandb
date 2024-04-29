provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "group" {
  name     = "${var.namespace}-resources"
  location = var.location
}

resource "azurerm_storage_account" "account" {
  name                     = var.namespace
  resource_group_name      = azurerm_resource_group.group.name
  location                 = azurerm_resource_group.group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = "true"

  blob_properties {
    cors_rule {
      allowed_headers    = ["*"]
      allowed_methods    = ["GET", "HEAD", "PUT"]
      allowed_origins    = ["*"]
      exposed_headers    = ["*"]
      max_age_in_seconds = 3600
    }
  }
}

resource "azurerm_storage_container" "container" {
  name                  = var.namespace
  storage_account_name  = azurerm_storage_account.account.name
  container_access_type = "private"
}

resource "azurerm_user_assigned_identity" "default" {
  name                = var.namespace
  location            = var.location
  resource_group_name = azurerm_resource_group.group.name
}

resource "azurerm_role_assignment" "principal" {
  scope                = azurerm_storage_account.account.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azurerm_user_assigned_identity.default.principal_id
}

resource "azurerm_role_assignment" "principal2" {
  scope                = azurerm_storage_account.account.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = azurerm_user_assigned_identity.default.principal_id
}