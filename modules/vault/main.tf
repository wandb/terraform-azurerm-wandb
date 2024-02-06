
data "azurerm_client_config" "current" {}

locals {
  vault_name           = "${var.namespace}-vault"
  vault_truncated_name = substr(local.vault_name, 0, min(length(local.vault_name), 24))
}

resource "azurerm_key_vault" "default" {
  name                = trim(local.vault_truncated_name, "-")
  location            = var.location
  resource_group_name = var.resource_group.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  enabled_for_disk_encryption = true

  sku_name = "standard"

  network_acls {
    bypass         = "AzureServices"
    default_action = "Allow"
  }

  tags = {
    "customer-ns" = var.namespace,
    "env"         = "managed-install"
  }
}

resource "azurerm_key_vault_access_policy" "parent" {
  key_vault_id = azurerm_key_vault.default.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions     = ["Get", "Backup", "Delete", "List", "Purge", "Recover", "Restore", "Rotate", "GetRotationPolicy"]
  secret_permissions  = ["Get", "Backup", "Delete", "List", "Purge", "Recover", "Restore", "Set"]
  storage_permissions = ["Get", "Backup", "Delete", "List", "Purge", "Recover", "Restore"]

  depends_on = [azurerm_key_vault.default]
}

resource "azurerm_key_vault_access_policy" "identity" {
  key_vault_id = azurerm_key_vault.default.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.identity_object_id

  key_permissions     = ["Get"]
  secret_permissions  = ["Get", "Delete", "List", "Purge", "Recover", "Restore", "Set"]
  storage_permissions = ["Get"]

  depends_on = [azurerm_key_vault.default]
}
