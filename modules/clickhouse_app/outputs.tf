output "namespace" {
  value       = kubernetes_namespace.clickhouse.metadata[0].name
  description = "The Kubernetes namespace where ClickHouse is deployed"
}

output "service_account_name" {
  value       = kubernetes_service_account.clickhouse.metadata[0].name
  description = "The Kubernetes service account name for ClickHouse"
}

output "clickhouse_endpoint" {
  value       = "chi-${local.installation_name}-${local.cluster_name}-0-0.${var.namespace}.svc.cluster.local:9000"
  description = "ClickHouse native protocol endpoint (first replica)"
}

output "clickhouse_http_endpoint" {
  value       = "chi-${local.installation_name}-${local.cluster_name}-0-0.${var.namespace}.svc.cluster.local:8123"
  description = "ClickHouse HTTP endpoint (first replica)"
}

output "clickhouse_service" {
  value       = "clickhouse-${local.installation_name}.${var.namespace}.svc.cluster.local"
  description = "ClickHouse service name (load-balanced across replicas)"
}

output "clickhouse_username" {
  value       = "weave"
  description = "ClickHouse username"
}

output "clickhouse_password_secret" {
  value       = kubernetes_secret.ch_db.metadata[0].name
  description = "Name of the Kubernetes secret containing the ClickHouse password"
}

output "keeper_endpoints" {
  value = [
    for i in range(var.clickhouse_replicas) :
    "chk-${local.keeper_name}-keeper-0-${i}.${var.namespace}.svc.cluster.local:2181"
  ]
  description = "ClickHouse Keeper endpoints"
}

output "cluster_name" {
  value       = local.cluster_name
  description = "ClickHouse cluster name"
}

output "remote_cluster_name" {
  value       = "weave_cluster"
  description = "ClickHouse remote cluster name for distributed queries"
}
