locals {
  keeper_name               = "wandb-ch-keeper"
  installation_name         = "wandb-ch"
  cluster_name              = "clickhouse"
  storage_account_url       = "https://${var.storage_account_name}.blob.core.windows.net"
  data_volume_size          = "50Gi"
  log_volume_size           = "10Gi"
  keeper_volume_size        = "10Gi"
  cache_size                = "40Gi"
  keeper_volume_storage_class = "managed-csi"
}

# Kubernetes namespace for ClickHouse
resource "kubernetes_namespace" "clickhouse" {
  metadata {
    name = var.namespace
  }
}

# Kubernetes service account with workload identity annotations
resource "kubernetes_service_account" "clickhouse" {
  metadata {
    name      = var.service_account_name
    namespace = kubernetes_namespace.clickhouse.metadata[0].name
    annotations = {
      "azure.workload.identity/client-id" = var.clickhouse_identity_client_id
    }
    labels = {
      "azure.workload.identity/use" = "true"
    }
  }
}

# Secret for ClickHouse database password
resource "kubernetes_secret" "ch_db" {
  metadata {
    name      = "ch-db"
    namespace = kubernetes_namespace.clickhouse.metadata[0].name
  }

  data = {
    password = "clickhouse123"
  }

  type = "Opaque"
}

# Helm release for ClickHouse operator
resource "helm_release" "clickhouse_operator" {
  name       = "ch-operator"
  repository = "https://docs.altinity.com/clickhouse-operator"
  chart      = "altinity-clickhouse-operator"
  version    = var.operator_chart_version
  namespace  = kubernetes_namespace.clickhouse.metadata[0].name

  # Wait for CRDs to be installed before proceeding
  wait          = true
  wait_for_jobs = true
  timeout       = 600

  depends_on = [kubernetes_namespace.clickhouse]
}

# Add a sleep to ensure CRDs are fully available
resource "time_sleep" "wait_for_crds" {
  depends_on = [helm_release.clickhouse_operator]

  create_duration = "30s"
}

