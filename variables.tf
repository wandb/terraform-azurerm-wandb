##########################################
# Common                                 #
##########################################
variable "namespace" {
  type        = string
  description = "String used for prefix resources."
}

variable "location" {
  type = string
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "Map of tags for resource"
}

variable "deletion_protection" {
  description = "If the instance should have deletion protection enabled. The database / Bucket can't be deleted when this value is set to `true`."
  type        = bool
  default     = true
}

variable "use_internal_queue" {
  type        = bool
  description = "Uses an internal redis queue instead of using azure queue."
  default     = false
}

variable "size" {
  default     = null
  description = "Deployment size"
  nullable    = true
  type        = string
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

variable "oidc_issuer" {
  type        = string
  description = "A url to your Open ID Connect identity provider, i.e. https://cognito-idp.us-east-1.amazonaws.com/us-east-1_uiIFNdacd"
  default     = ""
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


##########################################
# DNS                                    #
##########################################
variable "domain_name" {
  type        = string
  default     = null
  description = "Domain for accessing the Weights & Biases UI."
}

variable "subdomain" {
  type        = string
  default     = null
  description = "Subdomain for accessing the Weights & Biases UI. Default creates record at Route53 Route."
}

variable "ssl" {
  type        = bool
  default     = true
  description = "Enable SSL certificate"
}

##########################################
# Database                               #
##########################################
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

##########################################
# Redis                                  #
##########################################
variable "create_redis" {
  type        = bool
  description = "Boolean indicating whether to provision an redis instance (true) or not (false)."
  default     = false
}

variable "redis_capacity" {
  type        = number
  description = "Number indicating size of an redis instance"
  default     = 2
}

##########################################
# External Bucket                        #
##########################################
# Most users will not need these settings. They are ment for users who want a
# bucket in a different account.

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


##########################################
# K8s                                    #
##########################################
variable "kubernetes_instance_type" {
  type        = string
  description = "Use for the Kubernetes cluster."
  default     = "Standard_D4a_v4"
}

variable "kubernetes_node_count" {
  default = 2
  type    = number
}

variable "cluster_sku_tier" {
  type        = string
  description = "The Azure AKS SKU Tier to use for this cluster (https://learn.microsoft.com/en-us/azure/aks/free-standard-pricing-tiers)"
  default     = "Free"
}

variable "node_pool_zones" {
  type        = list(string)
  description = "Availability zones for the node pool"
  default     = ["1", "2"]
}

variable "node_max_pods" {
  type        = number
  description = "Maximum number of pods per node"
  default     = 30
}

###########################################
# Application gateway private link        #
###########################################
variable "create_private_link" {
  type        = bool
  default     = false
  description = "Use for the azure private link."
}

variable "allowed_subscriptions" {
  type        = string
  description = "List of allowed customer subscriptions coma seperated values"
  default     = ""
}
##########################################
# Network                                #
##########################################

variable "allowed_ip_ranges" {
  description = "Allowed public IP addresses or CIDR ranges."
  type        = list(string)
  default     = []
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

##########################################
# vault key                              #
##########################################

variable "enable_storage_vault_key" {
  type        = bool
  default     = false
  description = "Flag to enable managed key encryption for the storage account."
}

variable "disable_storage_vault_key_id" {
  type        = bool
  default     = false
  description = "Flag to disable the `customer_managed_key` block, the properties 'encryption.identity, encryption.keyvaultproperties' cannot be updated in a single operation."
}

variable "enable_database_vault_key" {
  type        = bool
  default     = false
  description = "Flag to enable managed key encryption for the database. Once enabled, cannot be disabled."
}

## To support otel azure monitor sql and redis metrics need operator-wandb chart minimum version 0.14.0 
variable "azuremonitor" {
  type    = bool
  default = false
}

###########################################
# Weave Trace / Clickhouse                #
###########################################
variable "enable_clickhouse" {
  type        = bool
  description = "Provision clickhouse resources"
  default     = false
}

variable "clickhouse_endpoint_service_id" {
  type        = string
  description = "The service ID of the VPC endpoint service for Clickhouse"
  default     = ""
}

variable "clickhouse_service_location" {
  description = "The region where ClickHouse service is located"
  type        = string
  default     = ""
}
