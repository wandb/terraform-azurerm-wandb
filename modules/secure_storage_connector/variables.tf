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