variable "namespace" {
  type        = string
  description = "Prefix to use when creating resources"
}

variable "location" {
  type        = string
  description = "The Azure Region where resources will be created"
}

variable "oidc_issuer_url" {
  type        = string
  description = "OIDC Issuer URL from server deployment's AKS Cluster"
}

variable "deletion_protection" {
  description = "If the instance should have deletion protection enabled. The storage container can't be deleted when this value is set to `true`."
  type        = bool
  default     = true
}

variable "resource_group_name" {
  type        = string
  description = <<EOF
The name of the resource group in which to create the managed identity and storage account.
If not provided, a new resource group will be created and then managed by this terraform module.

If you don't set this variable the first time you apply these changes, don't set it for later applies either.
EOF
  default     = ""
}