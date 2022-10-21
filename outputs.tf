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
<<<<<<< HEAD
  value = var.external_bucket != "" ? "" : coalesce(var.storage_account, local.account_name, "")
}

output "storage_container" {
  value = coalesce(var.external_bucket, var.blob_container, local.container_name)
}

output "external_bucket" {
  value = var.external_bucket != "" ? var.external_bucket : ""
=======
  value = module.storage.account
}

output "storage_container" {
  value = module.storage.container
>>>>>>> 630ce59 (Revert "feat: Add storage account creds")
}
