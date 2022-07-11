variable "namespace" {
  type        = string
  description = "Friendly name prefix used for tagging and naming Azure resources."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the MySQL Server."
}

variable "location" {
  type        = string
  description = "Specifies the supported Azure location where the resource exists."
}

variable "sku_name" {
  type        = string
  default     = "GP_Gen5_4"
  description = "Specifies the SKU Name for this MySQL Server"
}

variable "database_version" {
  description = "Version for MYSQL"
  type        = string
  default     = "8.0"

  validation {
    condition     = contains(["5.7", "8.0"], var.database_version)
    error_message = "We only support MySQL: \"5.7\"; \"8.0\"."
  }
}