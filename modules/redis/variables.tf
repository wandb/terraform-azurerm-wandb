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

variable "sku_name" {
  type        = string
  default     = "Balanced_B10"
  description = "Azure Managed Redis SKU name, for example Balanced_B10."
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "Map of tags for resource"
}

variable "private_endpoint_enabled" {
  type        = bool
  default     = false
  description = "Whether to disable public access and create a private endpoint for Azure Managed Redis."
}

variable "private_endpoint_subnet_id" {
  type        = string
  default     = null
  description = "Subnet ID in which to create the Azure Managed Redis private endpoint. Required when private_endpoint_enabled is true."
}

variable "private_dns_zone_id" {
  type        = string
  default     = null
  description = "ID of the privatelink.redis.azure.net private DNS zone. Required when private_endpoint_enabled is true."
}
