variable "subscription_id" {
  type    = string
  default = "**"
}

variable "namespace" {
  type        = string
  description = "String used for prefix resources."
  default = ""
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
  default = ""
  description = "Domain for accessing the Weights & Biases UI."
}

variable "subdomain" {
  type        = string
  default     = ""
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
  default = ""
  }


variable "tags" {
  default     = {}
  type        = map(string)
  description = "Map of tags for resource"
}



variable "oidc_client_id" {
  type        = string
  description = "The Client ID of application in your identity provider"
  default     = ""
}

variable "oidc_secret" {
  type        = string
  description = "The Client secret of application in your identity provider"
  default     = ""
  sensitive   = true
}

variable "oidc_auth_method" {
  type        = string
  description = "OIDC auth method"
  default     = "implicit"
  validation {
    condition     = contains(["pkce", "implicit"], var.oidc_auth_method)
    error_message = "Invalid OIDC auth method."
  }
}

variable "other_wandb_env" {
  type        = map(any)
  description = "Extra environment variables for W&B"
  default     = {}
}


variable "ssl" {
  type        = bool
  default     = true
  description = "Enable SSL certificate"
}

variable "database_version" {
  description = "Version for MySQL"
  type        = string
  default     = "5.7"
}

variable "database_availability_mode" {
  description = ""
  type        = string
  default     = "SameZone"

  validation {
    condition     = contains(["ZoneRedundant", "SameZone"], var.database_availability_mode)
    error_message = "Possible values: \"ZoneRedundant\"; \"SameZone\"."
  }
}

variable "database_sku_name" {
  type        = string
  default     = "GP_Standard_D4ds_v4"
  description = "Specifies the SKU Name for this MySQL Server"
}

variable "create_redis" {
  type        = bool
  description = "Boolean indicating whether to provision an redis instance (true) or not (false)."
  default     = false
}

variable "blob_container" {
  type        = string
  description = "Use an existing bucket."
  default     = ""
}

variable "storage_account" {
  type        = string
  description = "Azure storage account name"
  default     = ""
}

variable "storage_key" {
  type        = string
  description = "Azure primary storage access key"
  default     = ""
}

variable "external_bucket" {
  description = "config an external bucket"
  type        = any
  default     = null
}

variable "kubernetes_instance_type" {
  type        = string
  description = "Use for the Kubernetes cluster."
  default     = "Standard_D4a_v4"
}

variable "kubernetes_node_count" {
  default = 2
  type    = number
}

variable "weave_wandb_env" {
  type        = map(string)
  description = "Extra environment variables for W&B"
  default     = {}
}

variable "app_wandb_env" {
  type        = map(string)
  description = "Extra environment variables for W&B"
  default     = {}
}

variable "parquet_wandb_env" {
  type        = map(string)
  description = "Extra environment variables for W&B"
  default     = {}
}