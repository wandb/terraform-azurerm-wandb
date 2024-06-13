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

output "storage_account" {
  value = var.external_bucket != null ? "" : coalesce(var.storage_account, local.account_name, "")
}

output "storage_container" {
  value = var.external_bucket != null ? "" : coalesce(var.blob_container, local.container_name)
}

output "private_link_resource_id" {
  value = module.app_lb.gateway_id
}

output "private_link_sub_resource_name" {
  value = module.app_lb.frontend_ip_configuration_names
}