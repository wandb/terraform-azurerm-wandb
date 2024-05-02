output "resource_group_name" {
  value = azurerm_resource_group.group.name
}

output "blob_container" {
  value = "${module.storage.account.name}/${module.storage.container.name}"
}

output "managed_identity_id" {
  value = azurerm_user_assigned_identity.default.principal_id
}