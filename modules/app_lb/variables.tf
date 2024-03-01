variable "namespace" {
  type        = string
  description = "Friendly name prefix used for tagging and naming Azure resources."
}

variable "resource_group" {
  type = object({
    id       = string
    name     = string
    location = string
  })
  description = "The resource group in which to create the database."
}

variable "location" {
  type        = string
  description = "Specifies the supported Azure location where the resource exists."
}

variable "network" {
  type = object({
    name = string
  })
}

variable "public_subnet" {
  type = object({ id = string })
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "Map of tags for resource"
}

variable "byoc" {
  type        = bool
  description = "Bring your own cert"
}

variable "cert_name" {
  type        = string
  description = "The name of the certificate to use for the ingress"
  default     = "wandb-cert"
}

variable "cert_file" {
  type        = string
  description = "The path to the certificate file"
  default     = "./cert.pfx"
}

variable "cert_password" {
  type        = string
  description = "The password for the certificate"
  default     = ""
  sensitive   = true
}
