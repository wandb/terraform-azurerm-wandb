provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}



module "secure_storage_connector" {
  source              = "../../modules/secure_storage_connector"
  namespace           = var.namespace
  resource_group_name = var.resource_group_name
  oidc_issuer_url     = var.oidc_issuer_url
  deletion_protection = var.deletion_protection
}

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
