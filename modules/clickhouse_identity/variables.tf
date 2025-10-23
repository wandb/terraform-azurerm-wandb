variable "namespace" {
  type        = string
  description = "Friendly name prefix used for tagging and naming Azure resources."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group."
}

variable "location" {
  type        = string
  description = "The Azure location where the resources will be created."
}

variable "oidc_issuer_url" {
  type        = string
  description = "The OIDC issuer URL for the AKS cluster."
}

variable "k8s_namespace" {
  type        = string
  description = "The Kubernetes namespace where ClickHouse will be deployed."
  default     = "clickhouse"
}

variable "k8s_service_account_name" {
  type        = string
  description = "The Kubernetes service account name for ClickHouse."
  default     = "clickhouse"
}

variable "storage_account_id" {
  type        = string
  description = "The ID of the ClickHouse storage account to grant access to."
}
