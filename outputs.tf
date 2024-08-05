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

output "aks_node_count" {
  value = try(local.deployment_size[var.size].node_count, var.kubernetes_node_count)
}

output "aks_node_instance_type" {
  value = try(local.deployment_size[var.size].node_instance, var.kubernetes_instance_type)
}

output "database_instance_type" {
  value = try(local.deployment_size[var.size].db, var.database_sku_name)
}

output "client_id" {
  value = module.identity.identity.client_id
}

output "tenant_id" {
  value = module.identity.identity.tenant_id
}
