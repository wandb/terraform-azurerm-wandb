output "etcd_key_id" {
  value = azurerm_key_vault_key.etcd.id
}

output "vault" {
  value = azurerm_key_vault.default
}

output "vault_id" {
  value = azurerm_key_vault.default.id
}