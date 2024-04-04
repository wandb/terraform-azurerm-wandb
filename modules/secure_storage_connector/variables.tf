variable "namespace" {
  type        = string
  description = "Prefix to use when creating resources"
}

variable "location" {
  type        = string
  description = "The Azure Region where resources will be created"
}

variable "azure_principal_id" {
  description = "Azure principal ID that can access the blob storage"
  type        = string
}