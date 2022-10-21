locals {
  fqdn       = var.subdomain == null ? var.domain_name : "${var.subdomain}.${var.domain_name}"
  url_prefix = var.ssl ? "https" : "http"
  url        = "${local.url_prefix}://${local.fqdn}"
}

resource "azurerm_resource_group" "default" {
  name     = var.namespace
  location = var.location

  tags = var.tags
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

  tags = var.tags

  depends_on = [module.networking]
}

module "storage" {
<<<<<<< HEAD
  count               = (var.blob_container == "" && var.external_bucket == "") ? 1 : 0
=======
>>>>>>> 630ce59 (Revert "feat: Add storage account creds")
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

  gateway           = module.app_lb.gateway
  cluster_subnet_id = module.networking.private_subnet.id

  tags = var.tags

  depends_on = [module.app_lb]
}


locals {
<<<<<<< HEAD
  container_name  = try(module.storage[0].container.name, "")
  account_name    = try(module.storage[0].account.name, "")
  access_key      = try(module.storage[0].account.primary_access_key, "")
  queue_name      = try(module.storage[0].queue.name, "")
  blob_container  = coalesce(var.external_bucket, var.blob_container, local.container_name)
  storage_account = var.external_bucket != "" ? "" : coalesce(var.storage_account, local.account_name, "")
  storage_key     = var.external_bucket != "" ? "" : coalesce(var.storage_key, local.access_key, "")
  bucket          = var.external_bucket != "" ? var.external_bucket : "az://${local.storage_account}/${local.blob_container}"
  queue           = (var.use_internal_queue || var.blob_container == "" || var.external_bucket == "") ? "internal://" : "az://${local.account_name}/${local.queue_name}"
=======
  blob_container = local.create_blob_container ? "${module.storage.account.name}/${module.storage.container.name}" : var.blob_container
  queue          = var.use_internal_queue ? "internal://" : "az://${module.storage.account.name}/${module.storage.queue.name}"
>>>>>>> 630ce59 (Revert "feat: Add storage account creds")
}

module "aks_app" {
  source  = "wandb/wandb/kubernetes"
  version = "1.6.0"

  license = var.license

  host                       = local.url
  bucket                     = local.bucket
  bucket_queue               = local.queue
  bucket_aws_region          = var.external_bucket_region
  database_connection_string = "mysql://${module.database.connection_string}"
  # redis_connection_string    = local.redis_connection_string
  # redis_ca_cert              = local.redis_certificate

  oidc_client_id   = var.oidc_client_id
  oidc_issuer      = var.oidc_issuer
  oidc_auth_method = var.oidc_auth_method
  oidc_secret      = var.oidc_secret

  wandb_image   = var.wandb_image
  wandb_version = var.wandb_version

<<<<<<< HEAD
  other_wandb_env = merge(var.other_wandb_env, {
    "AZURE_STORAGE_KEY"     = local.storage_key
    "AZURE_STORAGE_ACCOUNT" = local.storage_account
  })
=======
  other_wandb_env = {
    "AZURE_STORAGE_KEY"     = module.storage.account.primary_access_key,
    "AZURE_STORAGE_ACCOUNT" = module.storage.account.name,
  }
>>>>>>> 630ce59 (Revert "feat: Add storage account creds")

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
