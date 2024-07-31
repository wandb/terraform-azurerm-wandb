module "identity" {
  count  = var.create_cmk ? 1 : 0
  source = "../identity"

  namespace      = var.prefix
  resource_group = { name = "${var.resource_group_name}", id = "byob" }
  location       = var.location
}

module "vault" {
  count          = var.create_cmk ? 1 : 0
  source         = "../vault"
  namespace      = var.prefix
  resource_group = { name = "${var.resource_group_name}", id = "byob" }
  location       = var.location

  identity_object_id      = module.identity[0].identity.principal_id
  depends_on              = [module.identity]
  tags                    = var.tags
  enable_purge_protection = var.enable_purge_protection
  enable_storage_key      = var.create_cmk
}

resource "azurerm_key_vault_access_policy" "wandb" {
  count        = var.create_cmk ? 1 : 0
  key_vault_id = module.vault[0].vault.id
  tenant_id    = var.tenant_id
  object_id    = var.client_id

  key_permissions         = ["Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore"]
  certificate_permissions = ["Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore"]
  secret_permissions      = ["Get", "List", "Set", "Delete", "Recover", "Backup", "Restore"]
}

module "storage" {
  source              = "../storage"
  create_queue        = false
  namespace           = var.prefix
  resource_group_name = var.resource_group_name
  location            = var.location
  deletion_protection = var.deletion_protection
  storage_key_id      = try(module.vault[0].vault_internal_keys[module.vault[0].vault_key_map.storage].id, null)
  identity_ids        = try(module.identity[0].identity.id, null)

  disable_storage_vault_key_id = var.disable_storage_vault_key_id
}

