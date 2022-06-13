variable "namespace" {
  type        = string
  description = "(Required) The name prefix for all resources created."
}

variable "region" {
    type        = string
    description = "Region to deploy the networking resources in."
    default     = "West US"
}

variable "create_vnet" {
    type        = bool
    description = "Controls if VNet should be created (it affects almost all resources)."
    default     = true
}

variable "vpc_cidr_block" {
    type        = string
    description = "(Optional) CIDR block for VPC."
    default     = "10.10.0.0/16"
}

variable "private_subnet_cidrs" {
    type        = string #TODO: list(string) is required
    description = "(Optional) List of private subnet CIDR ranges to create in VPC."
    default     = "10.10.1.0/24"
}

variable "public_subnet_cidrs" {
    type        = string #TODO: list(string) is required
    description = "(Optional) List of public subnet CIDR ranges to create in VPC."
    default     = "10.10.0.0/24"
}

variable "use_web_application_firewall" {
    type        = bool
    description = "Creates a WAF based on the value"
    default     = false
}

variable "private_ip" {
    type        = string
    description = "CIDR blocks for the public VPC subnets. Should be a list of 1 CIDR blocks."
    default     = "10.10.0.10"
}

variable "deployment_is_private" {
    type        = bool
    description = "If true, the load balancer will be placed in a private subnet, and the kubernetes API server endpoint will be private."
    default     = true
}

variable "firewall_ip_address_allow" {
    type        = list(string)
    description = "List of IP addresses that can access the instance via the API.  Defaults to anyone."
    default     = []
}