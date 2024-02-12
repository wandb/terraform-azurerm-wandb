variable "resource_group_name" {

  type = object({
    name = string,
    id = string
  })
  
}

variable "location" {
  description = "Resource Group location"
  type        = string
}

variable "prefix" {
  type        = string
  description = "Prefix of the storage account and storage container."
}

variable "deletion_protection" {
  description = "If the instance should have deletion protection enabled. The storage container can't be deleted when this value is set to `true`."
  type        = bool
  default     = true
}

variable "rg_name" {
    type        = string
}


variable "create_cmk" {
  type = bool
}