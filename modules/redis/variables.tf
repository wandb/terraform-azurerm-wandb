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
  default     = "Standard"
  description = "Specifies the SKU Name for this Redis instance"
}

variable "family" {
  type    = string
  default = "C"
}

variable "capacity" {
  type    = number
  default = 2
}


variable "tags" {
  description = "Map of tags for resource"
  nullable = "false"
  type        = map(string)
}