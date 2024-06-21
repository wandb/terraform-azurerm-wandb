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

variable "node_pool_vm_count" {
  type = number
}

variable "sku_tier" {
  type    = string
  default = "Free"
}

variable "max_pods" {
  type        = number
  description = "Maximum number of pods per node"
  default     = 30
}

variable "node_pool_zones" {
  type        = list(string)
  description = "Availability zones for the node pool"
  default     = ["1", "2"]
}