variable "namespace" {
  description = "A globally unique environment name for blob storage."
  type        = string
}

variable "region" {
    description = "The region where you want to deploy the resources"
    type        = string
    default     = "West US"
}

variable "kubernetes_api_is_private" {
  description = "If true, the kubernetes API server endpoint will be private."
  type        = bool
  default     = false
}