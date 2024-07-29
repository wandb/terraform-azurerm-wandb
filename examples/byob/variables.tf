variable "rg_name" {
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
variable "enable_encryption" {
  type = bool
}

variable "tags" {
  type        = map(string)
  description = "Map of tags for resource"
}