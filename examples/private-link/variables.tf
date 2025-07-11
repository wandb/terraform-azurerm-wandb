variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Existing resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

# Network Configuration
variable "create_network" {
  description = "Whether to create a new network and subnet"
  type        = bool
  default     = false
}

variable "new_vnet_name" {
  description = "Name for the new Virtual Network (if created)"
  type        = string
  default     = ""
}

variable "new_vnet_address_space" {
  description = "Address space for the new Virtual Network"
  type        = list(string)
  default     = []
}

variable "new_subnet_name" {
  description = "Name for the new Subnet (if created)"
  type        = string
  default     = ""
}

variable "new_subnet_address_prefixes" {
  description = "Address prefixes for the new Subnet"
  type        = list(string)
  default     = []
}

variable "existing_vnet_name" {
  description = "Name of the existing Virtual Network (if not creating a new one)"
  type        = string
  default     = ""
}

variable "existing_subnet_name" {
  description = "Name of the existing Subnet (if not creating a new one)"
  type        = string
  default     = ""
}

# Private Endpoint Configuration
variable "private_endpoint_name" {
  description = "Private Endpoint name"
  type        = string
}

variable "private_link_resource_id" {
  description = "Resource ID of the Private Link service"
  type        = string
}

variable "private_link_sub_resource_name" {
  description = "Subresource name for Private Link connection"
  type        = string
}

# DNS Configuration
variable "create_private_dns_zone" {
  description = "Whether to create a new private DNS zone"
  type        = bool
  default     = false
}

variable "existing_private_dns_zone_id" {
  description = "ID of an existing private DNS zone"
  type        = string
  default     = ""
}

variable "existing_private_dns_zone_name" {
  description = "Name of the existing private DNS zone"
  type        = string
  default     = ""
}

variable "private_dns_zone_name" {
  description = "Name of the private DNS zone (if creating a new one)"
  type        = string
  default     = ""
}

variable "dns_name_a_record" {
  description = "The DNS name for the A record pointing to the Private Endpoint"
  type        = string
}

variable "dns_link_name" {
  description = "Private DNS link name"
  type        = string
}