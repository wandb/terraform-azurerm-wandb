variable "namespace" {
  description = "A globally unique environment name for blob storage."
  type        = string
}

variable "region" {
    description = "The region where you want to deploy the resources"
    type        = string
    default     = "West US"
}

#TODO: Add customization options for bucket and queue