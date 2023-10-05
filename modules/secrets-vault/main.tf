resource "azurerm_key_vault" "wandb" {
  access_policy                   = []
  enabled_for_deployment          = false
  enabled_for_disk_encryption     = false 
  enable_rbac_authorization       = true
  enabled_for_template_deployment = false
  location                        = data.azurerm_resource_group.wandb.location
  name                            = "wandb-${var.namespace}"
  purge_protection_enabled        = false
  resource_group_name             = data.azurerm_resource_group.wandb.name
  sku_name                        = "standard"
  soft_delete_retention_days      = 3
  tenant_id                       = data.azurerm_client_config.current.tenant_id

  network_acls {
    bypass = "AzureServices"
    default_action = "Deny"
    virtual_network_subnet_ids = var.k8s_subnet_ids
  }
}

resource "azurerm_key_vault_access_policy" "wandb" {
  key_vault_id = azurerm_key_vault.wandb.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
   "Get",
  ]

  secret_permissions = [
   "Get", "Backup", "Delete", "List", "Purge", "Recover", "Restore", "Set",
  ]

  storage_permissions = [
    "Get",
  ]
}