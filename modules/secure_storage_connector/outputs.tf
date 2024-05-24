output "storage_account_name" {
  value = module.storage.account.name
}

output "storage_container_name" {
  value = module.storage.container.name
}

output "managed_identity_client_id" {
  value = azurerm_user_assigned_identity.default.client_id
}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}