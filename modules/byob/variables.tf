variable "resource_group_name" {
  description = "Resource Group name"
  type        = string
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
