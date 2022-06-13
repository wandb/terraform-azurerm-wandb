variable "namespace" {
  type        = string
  description = "(Required) The name prefix for all resources created."
}

variable "region" {
    type        = string
    description = "Region to deploy the networking resources in."
    default     = "West US"
}

variable "db_admin" {
    type        = string
    description = "Username for the database instance. NOTE: Database is not publicly accessible by default."
    default     = "wandb"
    sensitive   = true
}

variable "db_password" {
    type        = string
    description = "Password for the database instance. NOTE: Database is not publicly accessible by default."
    sensitive   = true
}

variable "mysql_version" {
    type        = string
    description = "Choose between 5.7 and 8.0 versions"
    default     = "8.0"
}
