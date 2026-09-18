variable "identity_object_id" {
  type = string
}

variable "additional_list_only_principal_ids" {
  type        = set(string)
  description = "Tenant-local principal object IDs allowed to list key, secret, and certificate metadata."
  default     = []
  nullable    = false

  validation {
    condition = alltrue([
      for id in var.additional_list_only_principal_ids :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", id))
    ])
    error_message = "Additional list-only principals must be non-null UUID object IDs."
  }
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
