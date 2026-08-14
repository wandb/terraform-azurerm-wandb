
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
  purge_protection_enabled = false
  # Azure Database for MySQL customer-managed keys require a 90-day soft-delete
  # retention period.
  soft_delete_retention_days  = 90
  enabled_for_disk_encryption = true
  # Public mode supports Terraform runs from laptops and hosted runners without
  # VNet connectivity. Private mode disables public access and relies on the
  # conditionally created private endpoint and vaultcore private DNS zone.
  public_network_access_enabled = var.network_access == "Public"

  sku_name = "standard"

  network_acls {
    bypass         = "AzureServices"
    default_action = var.network_access == "Private" ? "Deny" : "Allow"
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "default" {
  count = var.network_access == "Private" ? 1 : 0

  name                = "${var.namespace}-key-vault"
  location            = var.location
  resource_group_name = var.resource_group.name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.namespace}-key-vault"
    private_connection_resource_id = azurerm_key_vault.default.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "key-vault"
    private_dns_zone_ids = [var.private_dns_zone_id]
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

  depends_on = [azurerm_key_vault_access_policy.parent, azurerm_key_vault_access_policy.identity, azurerm_private_endpoint.default]
}

resource "azurerm_key_vault_key" "intenral_encryption_keys" {
  for_each     = { for v in local.vault_key_map : v => v if v != null }
  name         = each.value
  key_vault_id = azurerm_key_vault.default.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

  depends_on = [azurerm_key_vault_access_policy.parent, azurerm_key_vault_access_policy.identity, azurerm_private_endpoint.default]
}

resource "random_password" "weave_worker_auth" {
  length  = 32
  special = true
}

resource "azurerm_key_vault_secret" "weave_worker_auth" {
  name         = "weave-worker-auth"
  value        = random_password.weave_worker_auth.result
  key_vault_id = azurerm_key_vault.default.id

  depends_on = [azurerm_key_vault_access_policy.parent, azurerm_private_endpoint.default]
}

resource "kubernetes_secret" "weave_worker_auth" {
  metadata {
    name = "weave-worker-auth"
  }

  data = {
    key = random_password.weave_worker_auth.result
  }

  type = "Opaque"
}
