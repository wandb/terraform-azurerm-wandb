variable "namespace" {
  type        = string
  description = "Friendly name prefix used for tagging and naming Azure resources."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the storage account."
}

variable "location" {
  type        = string
  description = "Specifies the supported Azure location where the resource exists."
}

variable "container_name" {
  type        = string
  description = "Name of azure storage account container for ClickHouse data"
  default     = "clickhouse-data"
}

variable "replication_type" {
  type        = string
  description = "Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS."
  default     = "ZRS"
}

variable "deletion_protection" {
  type        = bool
  description = "If the storage account should have deletion protection enabled."
  default     = false
}

variable "tags" {
  default     = {}
  description = "Map of tags for resource"
  type        = map(string)
}
