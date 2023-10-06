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

module "redis" {
  source              = "./modules/redis"
  namespace           = var.namespace
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location



  depends_on = [module.networking]
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

  node_pool_vm_size  = var.kubernetes_instance_type
  node_pool_vm_count = var.kubernetes_node_count

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

module "cert_manager" {
  source    = "./modules/cert_manager"
  namespace = var.namespace

  ingress_class              = "azure/application-gateway"
  cert_manager_email         = "sysadmin@wandb.com"
  cert_manager_chart_version = "v1.9.1"
  tags                       = var.tags

  depends_on = [module.app_aks]
}

module "wandb" {
  source  = "wandb/wandb/helm"
  version = "1.2.0"

  depends_on = [
    module.app_aks,
    module.cert_manager,
    module.database,
    module.storage,
  ]
  operator_chart_version = "1.1.0"
  controller_image_tag   = "1.10.0"

  spec = {
    values = {
      global = {
        host    = local.url
        license = var.license

        bucket = {
          provider  = "az"
          name      = local.storage_account
          path      = local.blob_container
          accessKey = local.storage_key
        }

        mysql = {
          host     = module.database.address
          database = module.database.database_name
          user     = module.database.username
          password = module.database.password
          port     = 3306
        }
            
        redis = {
          host     = module.redis.instance.hostname
          password = module.redis.instance.primary_access_key
          port     = module.redis.instance.port
        }
      }

      ingress = {
        // TODO: For now we will use the existing issuer. We can move this into
        // the operator after testing. Trying to reduce the diff.
        issuer = { create = false }

        annotations = {
          "kubernetes.io/ingress.class"         = "azure/application-gateway"
          "cert-manager.io/cluster-issuer"      = "cert-issuer"
          "cert-manager.io/acme-challenge-type" = "http01"
        }

        tls = [
          { hosts = [trimprefix(trimprefix(local.url, "https://"), "http://")], secretName = "wandb-ssl-cert" }
        ]
      }

      weave = {
        persistence = {
          provider = "azurefile"
        }
      }

      mysql = { install = false }
      redis = { install = false }
    }
  }
}
