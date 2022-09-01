variable "prefix" {
  type        = string
  description = "Prefix of the storage account and storage container."
}

variable "deletion_protection" {
  description = "If the instance should have deletion protection enabled. The storage container can't be deleted when this value is set to `true`."
  type        = bool
  default     = true
}