variable "namespace" {
  type        = string
  description = "Friendly name prefix used for tagging and naming Azure resources."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the database."
}

variable "location" {
  type        = string
  description = "Specifies the supported Azure location where the resource exists."
}

variable "create_queue" {
  type    = bool
  default = true
}

variable "tags" {
  default     = {}
  description = "Map of tags for resource"
  type        = map(string)
}

variable "deletion_protection" {
  type        = bool
  description = "If the instance should have deletion protection enabled. The storage container can't be deleted when this value is set to `true`."
}

variable "storage_key_id" {
  type        = string
  description = "The ID of the storage key to use for the storage account."
  default     = null
}

variable "disable_storage_vault_key_id" {
  type        = bool
  description = "Flag to disable the `customer_managed_key` block, the properties 'encryption.identity, encryption.keyvaultproperties' cannot be updated in a single operation."
  default     = false
}

variable "identity_ids" {
  type        = string
  description = "The ID of the user assigned identity to use for the storage account."
  default     = null
}

variable "blob_container_name" {
  type        = string
  description = "Name of azure storage account container for storing blobs"
  default     = "wandb"
}
