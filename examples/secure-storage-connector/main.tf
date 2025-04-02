provider "azurerm" {
  features {}
  subscription_id = "26c54111-ca63-4feb-a59e-e70beb7f72eb"
  tenant_id       = "df6b81d4-a363-4352-b652-f7e584129264"
}



module "secure_storage_connector" {
  source              = "../../modules/secure_storage_connector"
  namespace           = "zacharyblasczyk"
  resource_group_name = "zacharyblasczyk"
  oidc_issuer_url     = "https://eastus.oic.prod-aks.azure.com/af722783-84b6-4adc-9c49-c792786eab4a/ba51b00b-03ae-4850-a8c4-beaa5f0bd79e/"
  deletion_protection = false
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
