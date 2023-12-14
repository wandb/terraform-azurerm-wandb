variable "namespace" {
  type        = string
  description = "Friendly name prefix used for tagging and naming Azure resources."
}

variable "resource_group" {
  type        = object({ name = string, id = string })
  description = "Resource Group where the Managed Kubernetes Cluster should exist."
}

variable "location" {
  type        = string
  description = "The location where the Managed Kubernetes Cluster should be created."
}

variable "identity_object_id" {
  type = string
}

variable "tags" {
  description = "Map of tags for resource"
  nullable = "false"
  type        = map(string)
}