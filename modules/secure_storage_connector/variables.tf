variable "namespace" {
  type        = string
  description = "Prefix to use when creating resources"
}

variable "location" {
  type        = string
  description = "The Azure Region where resources will be created"
}

#variable "deletion_protection" {
#  description = "If the Key Vault should have purge protection enabled."
#  type        = bool
#  default     = false
#}

variable "azure_principal_id" {
  description = "Azure principal ID that can access the blob storage"
  type        = string
}

variable "azure_client_id" {
  description = "Azure client ID that can access the blob storage"
  type        = string
}

#variable "resource_group_name" {
#  description = "Resource Group name"
#  type        = string
#}
#
#variable "location" {
#  description = "Resource Group location"
#  type        = string
#}
#
#variable "prefix" {
#  type        = string
#  description = "Prefix of the storage account and storage container."
#}
#
#variable "deletion_protection" {
#  description = "If the instance should have deletion protection enabled. The storage container can't be deleted when this value is set to `true`."
#  type        = bool
#  default     = true
#}
