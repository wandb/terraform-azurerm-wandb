variable "identity_object_id" {
  type = string
}

variable "location" {
  type        = string
  description = "The location where the Managed Kubernetes Cluster should be created."
}

variable "namespace" {
  type        = string
  description = "Friendly name prefix used for tagging and naming Azure resources."
}

variable "resource_group" {
  type        = object({ name = string, id = string })
  description = "Resource Group where the Managed Kubernetes Cluster should exist."
}

variable "tags" {
  type        = map(string)
  description = "Map of tags for resource"
}
variable "purge_protection_enabled" {
  type        = bool
  description = "Enable or disable purge protection for the Key Vault."
}