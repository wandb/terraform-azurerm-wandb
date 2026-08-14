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

variable "network_access" {
  type        = string
  description = "Key Vault data-plane network mode: Public or Private."
  default     = "Public"

  validation {
    condition     = contains(["Private", "Public"], var.network_access)
    error_message = "network_access must be either \"Private\" or \"Public\"."
  }
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "Subnet ID in which to create the Key Vault private endpoint. Required in Private mode."
  default     = null
}

variable "private_dns_zone_id" {
  type        = string
  description = "ID of the privatelink.vaultcore.azure.net private DNS zone. Required in Private mode."
  default     = null
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
