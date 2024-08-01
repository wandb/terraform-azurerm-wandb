output "etcd_key_id" {
  value = azurerm_key_vault_key.etcd.id
}

output "vault" {
  value = azurerm_key_vault.default
}

output "vault_id" {
  value = azurerm_key_vault.default.id
}

output "vault_internal_keys" {
  value = azurerm_key_vault_key.intenral_encryption_keys
}

output "vault_key_map" {
  value = local.vault_key_map
}
