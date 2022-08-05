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
