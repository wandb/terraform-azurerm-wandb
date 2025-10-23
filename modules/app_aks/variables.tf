variable "cluster_subnet_id" {
  type        = string
  description = "Network subnet id for cluster"
}

variable "etcd_key_vault_key_id" {
  description = "The ID of the key (stored in Key Vault) used to encryypt etcd's persistent storage."
  nullable    = false
  type        = string
}

variable "gateway" {
  type = object({ id = string })
}

variable "identity" {
  type = object({ id = string })
}

variable "location" {
  type        = string
  description = "The location where the Managed Kubernetes Cluster should be created."
}

variable "namespace" {
  type        = string
  description = "Friendly name prefix used for tagging and naming Azure resources."
}

variable "public_subnet" {
  type = object({ id = string })
}

variable "resource_group" {
  type        = object({ name = string, id = string })
  description = "Resource Group where the Managed Kubernetes Cluster should exist."
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "Map of tags for resource"
}

variable "node_pool_vm_size" {
  type = string
}

variable "node_pool_min_vm_per_az" {
  type = number
}

variable "node_pool_max_vm_per_az" {
  type = number
}

variable "node_pool_disk_size" {
  description = "The size of the OS disk volume in GiB for the root block device of node group instances."
  nullable    = false
  type        = number
  default     = 100
}

variable "sku_tier" {
  type    = string
  default = "Free"
}

variable "max_pods" {
  type        = number
  description = "Maximum number of pods per node"
  default     = 60
}

variable "node_pool_zones" {
  type        = list(string)
  description = "Availability zones for the node pool"
  default     = ["1", "2"]
}

variable "key_vault_id" {
  type        = string
  description = "The ID of the Azure Key Vault to grant CSI driver access to"
}

variable "k8s_namespace" {
  type        = string
  description = "The Kubernetes namespace where W&B resources will be deployed"
  default     = "default"
}

variable "secrets_store_csi_driver_version" {
  type        = string
  description = "The version of the Secrets Store CSI Driver Helm chart to install"
  default     = "1.4.7"
}

variable "secrets_store_csi_driver_provider_azure_version" {
  type        = string
  description = "The version of the Azure Key Vault Provider for Secrets Store CSI Driver to install"
  default     = "1.7.1"
}