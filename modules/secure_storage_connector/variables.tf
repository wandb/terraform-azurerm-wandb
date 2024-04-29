variable "namespace" {
  type        = string
  description = "Prefix to use when creating resources"
}

variable "location" {
  type        = string
  description = "The Azure Region where resources will be created"
}

variable "managed_identity_principal_id" {
  type        = string
  description = "The principal id of the managed identity"
}

variable "deletion_protection" {
  description = "If the instance should have deletion protection enabled. The storage container can't be deleted when this value is set to `true`."
  type        = bool
  default     = true
}