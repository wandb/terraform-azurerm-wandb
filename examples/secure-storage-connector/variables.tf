variable "subscription_id" {
  type        = string
  description = "The Azure Subscription ID where resources will be created"
}

variable "tenant_id" {
  type        = string
  description = "The Azure Tenant ID where resources will be created"
}

variable "namespace" {
  type        = string
  description = "Prefix to use when creating resources"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the managed identity and storage account"
}

variable "oidc_issuer_url" {
  type        = string
  description = "OIDC issuer URL from the AKS cluster that is meant to connect to this container. Make sure to include the trailing '/'"
}

variable "deletion_protection" {
  type        = bool
  description = "If the instance should have deletion protection enabled. The storage container can't be deleted when this value is set to `true`"
  default     = true
}
