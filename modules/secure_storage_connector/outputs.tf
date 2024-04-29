output "resource_group_name" {
  value = azurerm_resource_group.group.name
}

output "blob_container" {
  value = "${module.storage.account.name}/${module.storage.container.name}"
}