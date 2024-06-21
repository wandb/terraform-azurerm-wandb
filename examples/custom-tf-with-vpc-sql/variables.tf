variable "subscription_id" {
  nullable = false
  type     = string
  default  = ""
}

variable "namespace" {
  nullable    = false
  type        = string
  description = "String used for prefix resources."
  default     = ""
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
  default     = ""
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
  default     = ""
}

variable "database_sku_name" {
  type        = string
  default     = "GP_Standard_D4ds_v4"
  description = "Specifies the SKU Name for this MySQL Server"
}

variable "ssl" {
  type        = bool
  default     = true
  description = "Enable SSL certificate"
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "Map of tags for resource"
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

variable "deletion_protection" {
  description = "If the instance should have deletion protection enabled. The database / Bucket can't be deleted when this value is set to `true`."
  type        = bool
  default     = false
}

variable "use_internal_queue" {
  type        = bool
  description = "Uses an internal redis queue instead of using azure queue."
  default     = false
}

variable "other_wandb_env" {
  type        = map(any)
  description = "Extra environment variables for W&B"
  default     = {}
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

variable "vpc_name" {
  nullable    = false
  description = "virtual network name"
  type        = string
  default     = ""
}

variable "private_subnet" {
  nullable = false
  type     = string
  default  = ""
}

variable "public_subnet" {
  nullable = false
  type     = string
  default  = ""
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

variable "database_env" {
  nullable = false
  type = object({
    host          = string
    username      = string
    password      = string
    database_name = string
  })

  default = {
    host          = "**.mysql.database.azure.com"
    username      = "**"
    password      = "**"
    database_name = "**"
  }
}
