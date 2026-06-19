output "cluster" {
  value = azurerm_kubernetes_cluster.default
}

output "cluster_host" {
  value = azurerm_kubernetes_cluster.default.kube_config.0.host
}

output "cluster_client_certificate" {
  value = azurerm_kubernetes_cluster.default.kube_config.0.client_certificate
}

output "cluster_client_key" {
  value = azurerm_kubernetes_cluster.default.kube_config.0.client_key
}

output "cluster_ca_certificate" {
  value     = azurerm_kubernetes_cluster.default.kube_config.0.cluster_ca_certificate
  sensitive = true
}

output "oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.default.oidc_issuer_url
}

output "weave_worker_identity_client_id" {
  value       = azurerm_user_assigned_identity.weave_worker.client_id
  description = "The client ID of the managed identity used by weave workers for Key Vault access"
}

output "weave_worker_identity_principal_id" {
  value       = azurerm_user_assigned_identity.weave_worker.principal_id
  description = "The principal ID (object ID) of the managed identity used by weave workers"
}

output "tenant_id" {
  value       = data.azurerm_client_config.current.tenant_id
  description = "The Azure tenant ID"
}