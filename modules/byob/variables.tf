variable "resource_group_name" {
  type = string
}

variable "location" {
  description = "Resource Group location"
  type        = string
}

variable "prefix" {
  type        = string
  description = "Prefix of the storage account and storage container."
}

variable "deletion_protection" {
  description = "If the instance should have deletion protection enabled. The storage container can't be deleted when this value is set to `true`."
  type        = bool
  default     = true
}

variable "create_cmk" {
  type        = bool
  default     = false
  description = "Flag to create a Customer Managed Key for the Key Vault to encrypt the storage account."
}

variable "tags" {
  type        = map(string)
  description = "Map of tags for resource"
  default     = {}
}

variable "disable_storage_vault_key_id" {
  type        = bool
  default     = false
  description = "Flag to disable the `customer_managed_key` block, the properties 'encryption.identity, encryption.keyvaultproperties' cannot be updated in a single operation."
}

variable "tenant_id" {
  type        = string
  description = "The tenant ID for the Key Vault Access Policy. Get from `https://<WANDB_BASE_URL>/console/settings/advanced/spec/active`"
}

variable "client_id" {
  type        = string
  description = "The client ID (object id) for the Key Vault Access Policy. Get from `https://<WANDB_BASE_URL>/console/settings/advanced/spec/active`"
}
