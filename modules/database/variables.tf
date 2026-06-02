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
  default     = "GP_Standard_D4ds_v4"
  description = "Specifies the SKU Name for this MySQL Server"
}

variable "database_subnet_id" {
  type        = string
  description = "Network subnet id for database"
}

variable "database_private_dns_zone_id" {
  type        = string
  description = "The identity of the private DNS zone in which the database will be deployed."
}

variable "database_version" {
  description = "Version for MYSQL"
  type        = string
  default     = "5.7"
}

variable "database_version_keeper" {
  description = "When recreate_on_version_change is false, pins the random_pet keeper so the MySQL server name does not change when database_version is upgraded. Defaults to database_version (no-op on module upgrade when version is unchanged). Before changing database_version, set this explicitly to the version currently deployed and leave it unchanged."
  type        = string
  default     = null
  nullable    = true
}

variable "recreate_on_version_change" {
  description = "When true, the MySQL server name (and thus the server) is regenerated whenever database_version changes. Defaults to false; use database_version_keeper to pin the name instead."
  type        = bool
  default     = false
}

variable "database_availability_mode" {
  description = ""
  type        = string
  default     = "SameZone"

  validation {
    condition     = contains(["ZoneRedundant", "SameZone"], var.database_availability_mode)
    error_message = "Possible values: \"ZoneRedundant\"; \"SameZone\"."
  }
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "Map of tags for resource"
}

variable "deletion_protection" {
  type        = bool
  description = "If the instance should have deletion protection enabled. The database can't be deleted when this value is set to `true`."
}

variable "database_key_id" {
  type        = string
  description = "The Azure Key Vault key identifier for the database encryption key."
}

variable "identity_ids" {
  type        = string
  description = "The identity ids to assign to the database when database_key_id is passed."
}

variable "database_flags" {
  description = "MySQL server parameters to set on the Azure Database for MySQL flexible server. Merged with W&B defaults."
  type        = map(string)
  default     = {}
}

variable "sort_buffer_size" {
  description = "Specifies the sort_buffer_size value to set for the database"
  type        = number
  default     = 524288
}
