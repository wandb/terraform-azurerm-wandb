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
  description = "Use Redis for the internal queue instead of Azure Queue Storage."
  default     = false
}

variable "size" {
  default     = "small"
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
# Operator                               #
##########################################
variable "operator_chart_version" {
  type        = string
  description = "Version of the operator chart to deploy"
  default     = "1.4.2"
}

variable "controller_image_tag" {
  type        = string
  description = "Tag of the controller image to deploy"
  default     = "1.20.0"
}

variable "enable_helm_operator" {
  type        = bool
  default     = true
  description = "Enable or disable applying and releasing W&B Operator chart"
}

variable "enable_helm_wandb" {
  type        = bool
  default     = true
  description = "Enable or disable applying and releasing CR chart"
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
  description = "Optional subdomain for accessing the Weights & Biases UI. DNS records are managed outside this module."
}

variable "ssl" {
  type        = bool
  default     = true
  description = "Use HTTPS for the W&B application URL and ingress configuration."
}

# Passthrough for deployments that provide their own DNS-01 solver. The default
# public deployment installs cert-manager and uses an HTTP-01 challenge through
# Azure Application Gateway.
variable "use_dns_resolver" {
  type        = bool
  default     = false
  description = "[Internal Use Only] Skip the default cert-manager installation when an external DNS-01 certificate flow is provided."
}

##########################################
# Key Vault                              #
##########################################
variable "key_vault_network_access" {
  type        = string
  description = "Key Vault data-plane network mode. Public permits access from an external Terraform runner; Private disables public access and creates a private endpoint, subnet, private DNS zone, and VNet link."
  default     = "Public"

  validation {
    condition     = contains(["Private", "Public"], var.key_vault_network_access)
    error_message = "key_vault_network_access must be either \"Private\" or \"Public\"."
  }
}

##########################################
# Database                               #
##########################################
variable "database_version" {
  description = "Azure Database for MySQL Flexible Server version."
  type        = string
  default     = "8.4"
}

variable "database_availability_mode" {
  description = "High-availability mode for Azure Database for MySQL Flexible Server."
  type        = string
  default     = "SameZone"

  validation {
    condition     = contains(["ZoneRedundant", "SameZone"], var.database_availability_mode)
    error_message = "Possible values: \"ZoneRedundant\"; \"SameZone\"."
  }
}

variable "database_sku_name" {
  type        = string
  default     = null
  description = "Specifies the SKU Name for this MySQL Server. Defaults to null and value from deployment-size.tf is used"
}

variable "database_flags" {
  description = "MySQL server parameters to set on the Azure Database for MySQL flexible server. Merged with W&B defaults."
  type        = map(string)
  default     = {}
}

variable "database_sort_buffer_size" {
  description = "Specifies the sort_buffer_size value to set for the database"
  type        = number
  default     = 524288
}

##########################################
# Redis                                  #
##########################################
variable "create_redis" {
  type        = bool
  description = "Whether to provision an Azure Managed Redis instance."
  default     = true
}

variable "redis_sku_name" {
  type        = string
  description = "Azure Managed Redis SKU. When null, the selected deployment size determines the SKU."
  default     = null
}

variable "create_redis_private_endpoint" {
  type        = bool
  description = "Whether to disable Redis public access and create a private endpoint plus private DNS integration in the module VNet."
  default     = true
}

variable "use_external_redis" {
  type        = bool
  description = "Use an externally managed Redis instance instead of the module-managed instance."
  default     = false
}

variable "external_redis_host" {
  type        = string
  description = "Hostname of the externally managed Redis instance."
  default     = null
}

variable "external_redis_port" {
  type        = string
  description = "Port of the externally managed Redis instance."
  default     = null
}

variable "external_redis_params" {
  type        = object({})
  description = "Connection parameters passed to the W&B chart for an externally managed Redis instance."
  default     = null
}

variable "use_ctrlplane_redis" {
  description = "Whether redis is deployed in the cluster via ctrlplane"
  type        = bool
  default     = false
}

variable "use_chainguard_redis" {
  description = "Whether CHAINGUARD redis is deployed in the cluster"
  type        = bool
  default     = false
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
# Bucket path                            #
##########################################
# This setting is meant for users who want to store all of their instance-level
# bucket's data at a specific path within their bucket. It can be set both for
# external buckets or the bucket created by this module.
variable "bucket_path" {
  description = "path of where to store data for the instance-level bucket"
  type        = string
  default     = ""
}

##########################################
# K8s                                    #
##########################################
variable "kubernetes_instance_type" {
  description = "Instance type for primary node group. Defaults to null and value from deployment-size.tf is used"
  type        = string
  default     = null
}

variable "kubernetes_min_node_per_az" {
  description = "Minimum number of nodes for the AKS cluster. Defaults to null and value from deployment-size.tf is used"
  type        = number
  default     = null
}

variable "kubernetes_max_node_per_az" {
  description = "Maximum number of nodes for the AKS cluster. Defaults to null and value from deployment-size.tf is used"
  type        = number
  default     = null
}

variable "kubernetes_node_disk_size_gb" {
  type        = number
  description = "Size of the node root volume in GB."
  default     = null
}

variable "kubernetes_cluster_tags" {
  description = "A map of tags to apply to all resources managed by the AKS cluster"
  type        = map(string)
  default     = {}
}

variable "cluster_sku_tier" {
  type        = string
  description = "The Azure AKS SKU Tier to use for this cluster (https://learn.microsoft.com/en-us/azure/aks/free-standard-pricing-tiers)"
  default     = "Free"
}

variable "node_pool_zones" {
  type        = list(string)
  description = "Availability zones for the node pool"
  default     = null
}

variable "node_pool_num_zones" {
  type        = number
  description = "Number of availability zones to use for the node pool when node_pool_zones is not set. If neither are set, 3 zones will be used"
  default     = 2
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
# ClickHouse endpoint                     #
###########################################
variable "clickhouse_private_endpoint_service_name" {
  type        = string
  description = "ClickHouse private endpoint 'Service name' (ends in .azure.privatelinkservice)."
  default     = ""
}

variable "clickhouse_region" {
  type        = string
  description = "ClickHouse region (eastus2, westus3, etc)."
  default     = ""
}

#########
# Lumen #
#########

variable "lumen_agent_wif_audience" {
  description = "the audience for a dedicated customer's WIF pool for a lumen agent"
  type        = string
  default     = ""
}

variable "lumen_data_root" {
  description = "object storage to which config data is written"
  type        = string
  default     = ""
}
