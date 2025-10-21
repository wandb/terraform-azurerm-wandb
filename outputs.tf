output "fqdn" {
  value       = local.fqdn
  description = "The FQDN to the W&B application"
}

output "address" {
  value = module.app_lb.address
}

output "url" {
  value       = local.url
  description = "The URL to the W&B application"
}

output "cluster_host" {
  value = module.app_aks.cluster_host
}

output "cluster_client_certificate" {
  value = module.app_aks.cluster_client_certificate
}

output "cluster_client_key" {
  value = module.app_aks.cluster_client_key
}

output "cluster_ca_certificate" {
  value     = module.app_aks.cluster_ca_certificate
  sensitive = true
}

output "oidc_issuer_url" {
  value = module.app_aks.oidc_issuer_url
}

output "weave_worker_identity_client_id" {
  value       = module.app_aks.weave_worker_identity_client_id
  description = "The client ID of the managed identity used by weave workers for Key Vault access"
}

output "weave_worker_identity_principal_id" {
  value       = module.app_aks.weave_worker_identity_principal_id
  description = "The principal ID (object ID) of the managed identity used by weave workers"
}

output "key_vault_name" {
  value       = module.vault.vault.name
  description = "The name of the Azure Key Vault"
}

output "weave_worker_auth_secret_name" {
  value       = module.vault.weave_worker_auth_secret_name
  description = "The name of the weave worker authentication secret in Azure Key Vault (cloudSecretName)"
}

output "private_link_resource_id" {
  value = module.app_lb.gateway_id
}

output "private_link_sub_resource_name" {
  value = module.app_lb.frontend_ip_configuration_names
}

output "standardized_size" {
  value = var.size
}

output "aks_min_node_count" {
  value = local.kubernetes_min_node_per_az
}

output "aks_max_node_count" {
  value = local.kubernetes_max_node_per_az
}

output "aks_node_instance_type" {
  value = local.kubernetes_instance_type
}

output "database_instance_type" {
  value = local.database_sku_name
}

output "client_id" {
  value = module.identity.identity.client_id
}

output "tenant_id" {
  value = module.identity.identity.tenant_id
}

output "wandb_spec" {
  value     = local.spec
  sensitive = true
}

output "bufstream_storage_account_name" {
  value       = module.bufstream.storage_account_name
  description = "Bufstream Azure Storage Account name"
}

output "bufstream_container_name" {
  value       = module.bufstream.container_name
  description = "Bufstream Azure Storage Container name"
}

output "bufstream_storage_account_key" {
  value       = module.bufstream.storage_account_key
  description = "Bufstream Azure Storage Account primary access key"
}
