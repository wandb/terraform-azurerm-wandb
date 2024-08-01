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

variable "enable_storage_vault_key" {
  type        = bool
  default     = false
  description = "Flag to enable managed key encryption for the storage account."
}

variable "enable_database_vault_key" {
  type        = bool
  default     = false
  description = "Flag to enable managed key encryption for the database. Once enabled, cannot be disabled or you will loose access to the database."
}

variable "enable_purge_protection" {
  type        = bool
  default     = false
  description = "Flag to enable purge protection for the Azure Key Vault. Once enabled, cannot be disabled."
}
