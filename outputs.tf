output "address" {
  value = module.app_lb.address
}

output "cluster_ca_certificate" {
  value     = module.app_aks.cluster_ca_certificate
  sensitive = true
}

output "cluster_client_certificate" {
  value = module.app_aks.cluster_client_certificate
}

output "cluster_client_key" {
  value = module.app_aks.cluster_client_key
}

output "cluster_host" {
  value = module.app_aks.cluster_host
}

output "cluster_id" {
  value = module.app_aks.cluster_id
}

output "cluster_identity" {
  value = module.app_aks.cluster_identity
}

output "external_bucket" {
  value = var.external_bucket != "" ? var.external_bucket : ""
}

output "fqdn" {
  value       = local.fqdn
  description = "The FQDN to the W&B application"
}

output "storage_account" {
  value = var.external_bucket != "" ? "" : coalesce(var.storage_account, local.account_name, "")
}

output "storage_container" {
  value = coalesce(var.external_bucket, var.blob_container, local.container_name)
}

output "url" {
  value       = local.url
  description = "The URL to the W&B application"
}
