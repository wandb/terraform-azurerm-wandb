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
  type        = map(string)
  description = "Map of tags for resource"
}

variable "deletion_protection" {
  description = "If the instance should have deletion protection enabled. The storage container can't be deleted when this value is set to `true`."
  type        = bool
}

variable "storage_key_id" {
  type = string
}

variable "disable_storage_vault_key_id" {
  type        = bool
  default     = false
  description = "Flag to disable the `customer_managed_key` block, the properties 'encryption.identity, encryption.keyvaultproperties' cannot be updated in a single operation."
}

variable "identity_ids" {
  type = string
}

variable "blob_container_name" {
  description = "Name of azure storage account container for storing blobs"
  type        = string
  default     = "wandb"
}
