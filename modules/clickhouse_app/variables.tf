variable "namespace" {
  type        = string
  description = "Kubernetes namespace for ClickHouse deployment"
  default     = "clickhouse"
}

variable "clickhouse_replicas" {
  type        = number
  description = "Number of ClickHouse replicas for high availability"
  default     = 3
}

variable "clickhouse_image" {
  type        = string
  description = "ClickHouse server image"
  default     = "clickhouse/clickhouse-server:25.3.5.42"
}

variable "keeper_image" {
  type        = string
  description = "ClickHouse Keeper image"
  default     = "clickhouse/clickhouse-keeper:25.3.5.42"
}

variable "clickhouse_memory_request" {
  type        = string
  description = "Memory request for ClickHouse pods"
  default     = "2Gi"
}

variable "clickhouse_memory_limit" {
  type        = string
  description = "Memory limit for ClickHouse pods"
  default     = "16Gi"
}

variable "clickhouse_cpu_request" {
  type        = string
  description = "CPU request for ClickHouse pods"
  default     = "1"
}

variable "clickhouse_cpu_limit" {
  type        = string
  description = "CPU limit for ClickHouse pods"
  default     = "2"
}

variable "keeper_memory_request" {
  type        = string
  description = "Memory request for Keeper pods"
  default     = "256M"
}

variable "keeper_memory_limit" {
  type        = string
  description = "Memory limit for Keeper pods"
  default     = "4Gi"
}

variable "keeper_cpu_request" {
  type        = string
  description = "CPU request for Keeper pods"
  default     = "1"
}

variable "keeper_cpu_limit" {
  type        = string
  description = "CPU limit for Keeper pods"
  default     = "2"
}

variable "storage_class_data" {
  type        = string
  description = "Storage class for ClickHouse data volumes"
  default     = "managed-csi-premium"
}

variable "storage_class_logs" {
  type        = string
  description = "Storage class for ClickHouse log volumes"
  default     = "managed-csi"
}

variable "storage_account_name" {
  type        = string
  description = "Azure storage account name for ClickHouse blob storage"
}

variable "storage_container_name" {
  type        = string
  description = "Azure blob container name for ClickHouse data"
}

variable "clickhouse_identity_client_id" {
  type        = string
  description = "Azure workload identity client ID for ClickHouse"
}

variable "service_account_name" {
  type        = string
  description = "Kubernetes service account name for ClickHouse workload identity"
  default     = "clickhouse"
}

variable "operator_chart_version" {
  type        = string
  description = "Version of the Altinity ClickHouse operator Helm chart"
  default     = "0.25.4"
}

variable "deploy_clickhouse_objects" {
  type        = bool
  description = "Deploy ClickHouse and Keeper CRD objects (installations). Set to false for first apply (installs operator and CRDs only), then true to deploy the actual ClickHouse clusters."
  default     = false
}
