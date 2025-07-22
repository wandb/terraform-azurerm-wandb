variable "subscription_id" {
  type    = string
  default = null
}

variable "namespace" {
  type        = string
  description = "String used for prefix resources."
}

variable "location" {
  type    = string
  default = "East US"
}

variable "oidc_issuer" {
  type        = string
  description = "A url to your Open ID Connect identity provider, i.e. https://cognito-idp.us-east-1.amazonaws.com/us-east-1_uiIFNdacd"
  default     = ""
}

variable "domain_name" {
  type        = string
  description = "Domain for accessing the Weights & Biases UI."
}

variable "subdomain" {
  type        = string
  default     = null
  description = "Subdomain for accessing the Weights & Biases UI. Default creates record at Route53 Route."
}

variable "wandb_version" {
  description = "The version of Weights & Biases local to deploy."
  type        = string
  default     = "latest"
}

variable "wandb_image" {
  description = "Docker repository of to pull the wandb image from."
  type        = string
  default     = "wandb/local"
}

variable "license" {
  type        = string
  description = "Your wandb/local license"
}

variable "database_sku_name" {
  type        = string
  default     = "GP_Standard_D4ds_v4"
  description = "Specifies the SKU Name for this MySQL Server"
}

variable "bucket_path" {
  description = "path of where to store data for the instance-level bucket"
  type        = string
  default     = ""
}