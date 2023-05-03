variable "resource_group_name" {
  description = "Resource Group name"
  type        = string
}

variable "location" {
  description = "Resource Group location"
  type        = string
}

variable "prefix" {
  description = "Storage Account prefix"
  type        = string
}

variable "deletion_protection" {
  description = "Storage Account delete protection"
  type        = bool
  default     = false
}
