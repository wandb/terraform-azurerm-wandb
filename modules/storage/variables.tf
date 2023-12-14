variable "namespace" {
  type        = string
  description = "Friendly name prefix used for tagging and naming Azure resources."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the database."
}

variable "location" {
  type        = string
  description = "Specifies the supported Azure location where the resource exists."
}

variable "create_queue" {
  type    = bool
  default = true
}

variable "deletion_protection" {
  description = "If the instance should have deletion protection enabled. The storage container can't be deleted when this value is set to `true`."
  type        = bool
}


variable "tags" {
  description = "Map of tags for resource"
  nullable = "false"
  type        = map(string)
}