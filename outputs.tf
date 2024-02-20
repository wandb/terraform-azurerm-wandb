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

output "storage_account" {
  value = var.external_bucket != null ? "" : coalesce(var.storage_account, local.account_name, "")
}

output "storage_container" {
  value = var.external_bucket != null ? "" : coalesce(var.blob_container, local.container_name)
}

output "aks_node_count" {
  value = local.deployment_size[var.size].node_count
}

output "aks_node_instance_type" {
  value = local.deployment_size[var.size].node_instance
}

output "database_instance_type" {
  value = local.deployment_size[var.size].db
}

output "redis_instance_type" {
  value = join("-", [local.deployment_size[var.size].cache_sku_name, local.deployment_size[var.size].cache_family, local.deployment_size[var.size].cache_capacity])
}

output "standardized_size" {
  value = var.size
}
