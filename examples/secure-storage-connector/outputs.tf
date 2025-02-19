output "storage_account_name" {
  value = module.secure_storage_connector.storage_account_name
}

output "storage_container_name" {
  value = module.secure_storage_connector.storage_container_name
}

output "managed_identity_client_id" {
  value = module.secure_storage_connector.managed_identity_client_id
}

output "tenant_id" {
  value = module.secure_storage_connector.tenant_id
}
