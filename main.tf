locals {
  fqdn       = var.subdomain == null ? var.domain_name : "${var.subdomain}.${var.domain_name}"
  url_prefix = var.ssl ? "https" : "http"
  url        = "${local.url_prefix}://${local.fqdn}"

  # Specifications for t-shirt sized deployments
  deployment_size = {
    small = {
      db = "Standard_E2ds_v4",
      node_count = 2,
      node_instance = "Standard_E2s_v5",
      cache_sku_name = "Standard",
      cache_family = "C",
      cache_capacity = 3,
    },
    medium = {
      db = "Standard_E4ds_v4",
      node_count = 2,
      node_instance = "Standard_E4s_v5",
      cache_sku_name = "Standard",
      cache_family = "C",
      cache_capacity = 3,
    },
    large = {
      db = "Standard_E8ds_v4",
      node_count = 2,
      node_instance = "Standard_E8s_v5",
      cache_sku_name = "Standard",
      cache_family = "C",
      cache_capacity = 4,
    },
    xlarge = {
      db = "Standard_E16ds_v4",
      node_count = 3,
      node_instance = "Standard_E8s_v5",
      cache_sku_name = "Standard",
      cache_family = "C",
      cache_capacity = 4,
    },
    xxlarge = {
      db = "Standard_E32ds_v4",
      node_count = 3,
      node_instance = "Standard_E16s_v5",
      cache_sku_name = "Standard",
      cache_family = "C",
      cache_capacity = 5,
    }
  }
}

resource "azurerm_resource_group" "default" {
  name     = var.namespace
  location = var.location

  tags = var.tags
}

module "identity" {
  source = "./modules/identity"

  namespace      = var.namespace
  resource_group = azurerm_resource_group.default
  location       = azurerm_resource_group.default.location
}

module "networking" {
  source              = "./modules/networking"
  namespace           = var.namespace
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location

  tags = var.tags
}

module "database" {
  source              = "./modules/database"
  namespace           = var.namespace
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location

  database_availability_mode   = var.database_availability_mode
  database_version             = var.database_version
  database_private_dns_zone_id = module.networking.database_private_dns_zone.id
  database_subnet_id           = module.networking.database_subnet.id

  deletion_protection = var.deletion_protection
  sku_name = coalesce(try(local.deployment_size[var.size].db, null), var.database_sku_name)

  tags = var.tags

  depends_on = [module.networking]
}

module "redis" {
  source              = "./modules/redis"
  namespace           = var.namespace
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location

  # Use the t-shirt sized deployment specifications if size is defined;
  # if not, use the value of the corresponding variable that may have been manually defined;
  # use the default value if neither has been defined
  sku_name = coalesce(try(local.deployment_size[var.size].cache_sku_name, null), var.redis_sku_name)
  family = coalesce(try(local.deployment_size[var.size].cache_family, null), var.redis_family)
  capacity = coalesce(try(local.deployment_size[var.size].cache_capacity, null), var.redis_capacity)
  depends_on = [module.networking]
}

module "vault" {
  source         = "./modules/vault"
  namespace      = var.namespace
  resource_group = azurerm_resource_group.default
  location       = azurerm_resource_group.default.location

  identity_object_id = module.identity.identity.principal_id
}

module "storage" {
  count               = (var.blob_container == "" && var.external_bucket == "") ? 1 : 0
  source              = "./modules/storage"
  namespace           = var.namespace
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  create_queue        = !var.use_internal_queue

  deletion_protection = var.deletion_protection

  tags = var.tags
}

module "app_lb" {
  source         = "./modules/app_lb"
  namespace      = var.namespace
  resource_group = azurerm_resource_group.default
  location       = azurerm_resource_group.default.location
  network        = module.networking.network
  public_subnet  = module.networking.public_subnet
}

module "app_aks" {
  source         = "./modules/app_aks"
  namespace      = var.namespace
  resource_group = azurerm_resource_group.default
  location       = azurerm_resource_group.default.location

  node_pool_vm_size  = coalesce(try(local.deployment_size[var.size].node_instance, null), var.kubernetes_instance_type)
  node_pool_vm_count = coalesce(try(local.deployment_size[var.size].node_count, null), var.kubernetes_node_count)

  identity = module.identity.identity

  gateway           = module.app_lb.gateway
  public_subnet     = module.networking.public_subnet
  cluster_subnet_id = module.networking.private_subnet.id

  tags = var.tags

  depends_on = [module.app_lb]
}

locals {
  container_name  = try(module.storage[0].container.name, "")
  account_name    = try(module.storage[0].account.name, "")
  access_key      = try(module.storage[0].account.primary_access_key, "")
  queue_name      = try(module.storage[0].queue.name, "")
  blob_container  = coalesce(var.external_bucket, var.blob_container, local.container_name)
  storage_account = var.external_bucket != "" ? "" : coalesce(var.storage_account, local.account_name, "")
  storage_key     = var.external_bucket != "" ? "" : coalesce(var.storage_key, local.access_key, "")
  bucket          = var.external_bucket != "" ? var.external_bucket : "az://${local.storage_account}/${local.blob_container}"
  queue           = (var.use_internal_queue || var.blob_container == "" || var.external_bucket == "") ? "internal://" : "az://${local.account_name}/${local.queue_name}"

  redis_connection_string = "redis://:${module.redis.instance.primary_access_key}@${module.redis.instance.hostname}:${module.redis.instance.port}"
}

locals {
  service_account_name = "wandb-serviceaccount"
}

resource "azurerm_federated_identity_credential" "app" {
  parent_id           = module.identity.identity.id
  name                = "${var.namespace}-app-credentials"
  resource_group_name = azurerm_resource_group.default.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = module.app_aks.oidc_issuer_url
  subject             = "system:serviceaccount:default:${local.service_account_name}"
}

data "azurerm_client_config" "current" {}

module "aks_app" {
  source  = "wandb/wandb/kubernetes"
  version = "1.14.0"

  service_account_name = local.service_account_name
  service_account_annotations = {
    "azure.workload.identity/client-id" = module.identity.identity.client_id
  }

  deployment_pod_labels = {
    "azure.workload.identity/use" = "true"
  }

  service_account_labels = {
    "azure.workload.identity/use" = "true"
  }

  license = var.license

  host                       = local.url
  bucket                     = local.bucket
  bucket_queue               = local.queue
  bucket_aws_region          = var.external_bucket_region
  database_connection_string = "mysql://${module.database.connection_string}"
  redis_connection_string    = local.redis_connection_string

  oidc_client_id   = var.oidc_client_id
  oidc_issuer      = var.oidc_issuer
  oidc_auth_method = var.oidc_auth_method
  oidc_secret      = var.oidc_secret

  wandb_image   = var.wandb_image
  wandb_version = var.wandb_version

  other_wandb_env = merge(var.other_wandb_env, {
    "AZURE_STORAGE_KEY"     = local.storage_key
    "AZURE_STORAGE_ACCOUNT" = local.redis_connection_string,
    "GORILLA_CUSTOMER_SECRET_STORE_AZ_CONFIG_VAULT_URI" = module.vault.vault.vault_uri,
    "GORILLA_CUSTOMER_SECRET_STORE_SOURCE" = "az-secretmanager://wandb",
  })

  resource_limits   = var.resource_limits
  resource_requests = var.resource_requests

  # If we dont wait, tf will start trying to deploy while the work group is
  # still spinning up
  depends_on = [
    module.database,
    # module.redis,
    module.storage,
    module.app_aks,
  ]
}

module "cert_manager" {
  source    = "./modules/cert_manager"
  namespace = var.namespace

  ingress_class              = "azure/application-gateway"
  cert_manager_email         = "sysadmin@wandb.com"
  cert_manager_chart_version = "v1.9.1"
  tags                       = var.tags

  depends_on = [module.app_aks]
}

module "app_ingress" {
  source    = "./modules/app_ingress"
  fqdn      = local.fqdn
  namespace = var.namespace

  depends_on = [
    module.aks_app,
    module.cert_manager,
    module.app_aks,
  ]
}
