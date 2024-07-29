module "identity" {
  count  = var.create_cmk ? 1 : 0
  source = "../identity"

  namespace      = var.prefix
  resource_group = { name = "${var.rg_name}", id = "byob" }
  location       = var.location
}

module "vault" {
  count          = var.create_cmk ? 1 : 0
  source         = "../vault"
  namespace      = var.prefix
  resource_group = { name = "${var.rg_name}", id = "byob" }
  location       = var.location

  identity_object_id       = module.identity[0].identity.principal_id
  depends_on               = [module.identity]
  tags                     = var.tags
  purge_protection_enabled = var.purge_protection_enabled
}

resource "azurerm_key_vault_key" "Vault_key" {
  count        = var.create_cmk ? 1 : 0
  name         = "byob-managed-key"
  key_vault_id = module.vault[0].vault_id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey"
  ]

  depends_on = [
    module.vault
  ]
}
module "storage" {
  source              = "../storage"
  create_queue        = false
  namespace           = var.prefix
  resource_group_name = var.resource_group_name.name
  location            = var.location
  deletion_protection = var.deletion_protection
  wb_managed_key_id   = var.create_cmk == true ? azurerm_key_vault_key.Vault_key[0].versionless_id : null
  identity_ids        = var.create_cmk == true ? module.identity[0].identity.id : null
}

