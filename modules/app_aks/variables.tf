variable "cluster_subnet_id" {
  type        = string
  description = "Network subnet id for cluster"
}

variable "etcd_key_vault_key_id" {
  description = "ID of the Key Vault key used by AKS KMS to encrypt etcd data at rest."
  nullable    = false
  type        = string
}

variable "key_vault_network_access" {
  type        = string
  description = "Network access mode for the Key Vault used by AKS KMS; must match the vault configuration."
  default     = "Public"

  validation {
    condition     = contains(["Private", "Public"], var.key_vault_network_access)
    error_message = "key_vault_network_access must be either \"Private\" or \"Public\"."
  }
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
