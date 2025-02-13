variable "namespace" {
  type        = string
  description = "Prefix to use when creating resources"
}

variable "oidc_issuer_url" {
  type        = string
  description = "OIDC Issuer URL"
  default     = "https://accounts.google.com"
}

variable "deletion_protection" {
  description = "If the instance should have deletion protection enabled. The storage container can't be deleted when this value is set to `true`."
  type        = bool
  default     = true
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the managed identity and storage account."
}

variable "subscription_id" {
  type    = string
  default = null
}

variable "subject" {
  type        = string
  description = "The subject of the federated identity credential"
  default     = "101148871499660386821"
}

variable "audience" {
  type        = list(string)
  description = "The audience of the federated identity credential"
  default     = ["32555940559.apps.googleusercontent.com"]
}
