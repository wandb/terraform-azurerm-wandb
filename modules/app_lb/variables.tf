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

variable "private_subnet" {
  type        = string
  description = "Specifies the supported Azure subnet where the resource exists."
}

variable "private_link" {
  type = bool
  description = "Specifies the Azure private link creation"
}