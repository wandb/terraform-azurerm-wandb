variable "namespace" {
  type        = string
  description = "Friendly name prefix used for tagging and naming Azure resources."
}

variable "identity" {
  type = object({ id = string })
}

variable "resource_group" {
  type        = object({ name = string, id = string })
  description = "Resource Group where the Managed Kubernetes Cluster should exist."
}

variable "location" {
  type        = string
  description = "The location where the Managed Kubernetes Cluster should be created."
}

variable "cluster_subnet_id" {
  type        = string
  description = "Network subnet id for cluster"
}

variable "gateway" {
  type = object({ id = string })
}

variable "public_subnet" {
  type = object({ id = string })
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
