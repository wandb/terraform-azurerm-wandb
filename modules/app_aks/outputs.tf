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

output "kube_audit_log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace receiving AKS control-plane audit logs (null when audit logging is disabled)."
  value       = local.kube_audit_workspace_id
}