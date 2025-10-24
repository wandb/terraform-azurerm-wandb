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

###########################################
# ClickHouse Storage Outputs              #
###########################################
output "clickhouse_storage_account_name" {
  value       = local.clickhouse_storage_account_name
  description = "The name of the ClickHouse storage account"
}

output "clickhouse_container_name" {
  value       = local.clickhouse_container_name
  description = "The name of the ClickHouse storage container"
}

output "clickhouse_storage_primary_blob_endpoint" {
  value       = local.clickhouse_use_external_bucket ? null : module.clickhouse_storage[0].primary_blob_endpoint
  description = "The primary blob endpoint for the ClickHouse storage account"
}

output "clickhouse_identity_client_id" {
  value       = module.clickhouse_identity.client_id
  description = "The client ID of the ClickHouse managed identity"
}

output "clickhouse_identity_tenant_id" {
  value       = module.clickhouse_identity.tenant_id
  description = "The tenant ID of the ClickHouse managed identity"
}

output "clickhouse_k8s_namespace" {
  value       = var.clickhouse_k8s_namespace
  description = "The Kubernetes namespace for ClickHouse deployment"
}

output "clickhouse_k8s_service_account" {
  value       = var.clickhouse_k8s_service_account_name
  description = "The Kubernetes service account name for ClickHouse"
}

###########################################
# ClickHouse Application Outputs          #
###########################################
output "clickhouse_endpoint" {
  value       = module.clickhouse_app.clickhouse_endpoint
  description = "ClickHouse native protocol endpoint"
}

output "clickhouse_http_endpoint" {
  value       = module.clickhouse_app.clickhouse_http_endpoint
  description = "ClickHouse HTTP endpoint"
}

output "clickhouse_service" {
  value       = module.clickhouse_app.clickhouse_service
  description = "ClickHouse service name"
}

output "clickhouse_username" {
  value       = module.clickhouse_app.clickhouse_username
  description = "ClickHouse username"
}

output "clickhouse_cluster_name" {
  value       = module.clickhouse_app.cluster_name
  description = "ClickHouse cluster name"
}

output "clickhouse_remote_cluster_name" {
  value       = module.clickhouse_app.remote_cluster_name
  description = "ClickHouse remote cluster name for distributed queries"
}
