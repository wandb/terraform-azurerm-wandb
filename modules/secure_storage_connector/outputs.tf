output "resource_group_name" {
  value = azurerm_resource_group.group.name
}

output "managed_identity_name" {
  value = azurerm_user_assigned_identity.default.name
}

output "managed_identity_client_id" {
  value = azurerm_user_assigned_identity.default.client_id
}

output "storage_account_name" {
  value = module.storage.account.name
}

output "storage_container_name" {
  value = module.storage.container.name
}