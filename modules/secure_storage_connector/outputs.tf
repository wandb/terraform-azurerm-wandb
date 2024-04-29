output "storage_account_name" {
  value = azurerm_storage_account.account.name
}

output "container_name" {
  value = azurerm_storage_container.container.name
}

output "resource_group_name" {
  value = azurerm_resource_group.group.name
}

output "azurerm_user_assigned_identity" {
  value = azurerm_user_assigned_identity.default.name
}

