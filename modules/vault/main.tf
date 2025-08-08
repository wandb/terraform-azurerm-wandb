
data "azurerm_client_config" "current" {}

locals {
  vault_name           = "${var.namespace}-vault"
  vault_truncated_name = substr(local.vault_name, 0, min(length(local.vault_name), 24))
  max_key_length       = 127
  vault_key_map = {
    database = var.enable_database_vault_key ? substr("database-key-${var.namespace}", 0, local.max_key_length) : null
    storage  = var.enable_storage_vault_key ? substr("storage-key-${var.namespace}", 0, local.max_key_length) : null
  }
}

resource "azurerm_key_vault" "default" {
  name                     = trim(local.vault_truncated_name, "-")
  location                 = var.location
  resource_group_name      = var.resource_group.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled = true
  # https://learn.microsoft.com/en-us/azure/mysql/flexible-server/concepts-customer-managed-key#requirements-for-configuring-data-encryption-for-azure-database-for-mysql-flexible-server
  soft_delete_retention_days  = 90 # This must be 90 for azure msyql flex server encryption. 
  enabled_for_disk_encryption = true

  sku_name = "standard"

  network_acls {
    bypass         = "AzureServices"
    default_action = "Allow"
  }

  tags = var.tags
}

resource "azurerm_key_vault_access_policy" "parent" {
  key_vault_id = azurerm_key_vault.default.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions     = ["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "GetRotationPolicy", "List", "Purge", "Recover", "Restore", "Rotate"]
  secret_permissions  = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
  storage_permissions = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore"]

  depends_on = [azurerm_key_vault.default]
}

resource "azurerm_key_vault_access_policy" "identity" {
  key_vault_id = azurerm_key_vault.default.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.identity_object_id

  key_permissions     = ["Create", "Decrypt", "Encrypt", "Get", "List", "UnwrapKey", "WrapKey"]
  secret_permissions  = ["Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
  storage_permissions = ["Get", "List"]

  depends_on = [azurerm_key_vault.default]
}

resource "azurerm_key_vault_key" "etcd" {
  name         = "generated-etcd-key"
  key_vault_id = azurerm_key_vault.default.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey", ]

  depends_on = [azurerm_key_vault_access_policy.parent, azurerm_key_vault_access_policy.identity]
}

resource "azurerm_key_vault_key" "intenral_encryption_keys" {
  for_each     = { for v in local.vault_key_map : v => v if v != null }
  name         = each.value
  key_vault_id = azurerm_key_vault.default.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

  depends_on = [azurerm_key_vault_access_policy.parent, azurerm_key_vault_access_policy.identity]
}

resource "random_password" "weave_worker_auth" {
  length  = 32
  special = true
}

resource "azurerm_key_vault_secret" "weave_worker_auth" {
  name         = "weave-worker-auth"
  value        = random_password.weave_worker_auth.result
  key_vault_id = azurerm_key_vault.default.id
}

resource "kubernetes_secret" "weave_worker_auth" {
  metadata {
    name = "weave-worker-auth"
  }

  string_data = {
    key = random_password.weave_worker_auth.result
  }

  type = "Opaque"
}
