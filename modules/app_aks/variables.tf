variable "namespace" {
  type        = string
  description = "Friendly name prefix used for tagging and naming Azure resources."
}

variable "resource_group_name" {
  type        = string
  description = "Specifies the Resource Group where the Managed Kubernetes Cluster should exist."
}

variable "location" {
  type        = string
  description = "The location where the Managed Kubernetes Cluster should be created."
}

variable "cluster_subnet_id" {
  type        = string
  description = "Network subnet id for cluster"
}


variable "tags" {
  default     = {}
  type        = map(string)
  description = "Map of tags for resource"
}
