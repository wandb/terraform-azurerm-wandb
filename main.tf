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

  sku_name            = var.database_sku_name
  deletion_protection = var.deletion_protection

  tags = {
    "customer-ns" = var.namespace,
    "env"         = "managed-install"
  }

  depends_on = [module.networking]
}

module "redis" {
  source              = "./modules/redis"
  namespace           = var.namespace
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location

  depends_on = [module.networking]
}

module "vault" {
  source = "./modules/vault"

  identity_object_id = module.identity.identity.principal_id
  location           = azurerm_resource_group.default.location
  namespace          = var.namespace
  resource_group     = azurerm_resource_group.default

  tags = var.tags
}

module "storage" {
  count  = (var.blob_container == "" && var.external_bucket == null) ? 1 : 0
  source = "./modules/storage"

  namespace           = var.namespace
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  create_queue        = !var.use_internal_queue
  deletion_protection = var.deletion_protection

  tags = var.tags
}

module "app_lb" {
  source = "./modules/app_lb"

  namespace      = var.namespace
  resource_group = azurerm_resource_group.default
  location       = azurerm_resource_group.default.location
  network        = module.networking.network
  public_subnet  = module.networking.public_subnet

  tags = var.tags
}

module "app_aks" {
  source     = "./modules/app_aks"
  depends_on = [module.app_lb]

  cluster_subnet_id     = module.networking.private_subnet.id
  etcd_key_vault_key_id = module.vault.etcd_key_id
  gateway               = module.app_lb.gateway
  identity              = module.identity.identity
  location              = azurerm_resource_group.default.location
  namespace             = var.namespace
  node_pool_vm_count    = var.kubernetes_node_count
  node_pool_vm_size     = var.kubernetes_instance_type
  public_subnet         = module.networking.public_subnet
  resource_group        = azurerm_resource_group.default

  tags = var.tags
}

locals {
  container_name  = try(module.storage[0].container.name, "")
  account_name    = try(module.storage[0].account.name, "")
  access_key      = try(module.storage[0].account.primary_access_key, "")
  queue_name      = try(module.storage[0].queue.name, "")
  blob_container  = var.external_bucket == null ? coalesce(var.blob_container, local.container_name) : ""
  storage_account = var.external_bucket == null ? coalesce(var.storage_account, local.account_name) : ""
  storage_key     = var.external_bucket == null ? coalesce(var.storage_key, local.access_key) : ""
  bucket          = "az://${local.storage_account}/${local.blob_container}"
  queue           = (var.use_internal_queue || var.blob_container == "" || var.external_bucket == null) ? "internal://" : "az://${local.account_name}/${local.queue_name}"

  redis_connection_string = "redis://:${module.redis.instance.primary_access_key}@${module.redis.instance.hostname}:${module.redis.instance.port}"
}

locals {
  service_account_name = "wandb-app"
}

resource "azurerm_federated_identity_credential" "app" {
  parent_id           = module.identity.identity.id
  name                = "${var.namespace}-app-credentials"
  resource_group_name = azurerm_resource_group.default.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = module.app_aks.oidc_issuer_url
  subject             = "system:serviceaccount:default:${local.service_account_name}"
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


module "nginx_controller" {
  count = var.nginx_controller ? 1 : 0
  source = "./modules/nginx"
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
  operator_chart_version = "1.1.2"
  controller_image_tag   = "1.10.1"

  spec = {
    values = {
      global = {
        host    = local.url
        license = var.license

        bucket = var.external_bucket == null ? {
          provider  = "az"
          name      = local.storage_account
          path      = local.blob_container
          accessKey = local.storage_key
        } : var.external_bucket

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

        extraEnv = var.other_wandb_env

      }

      app = {
        extraEnv = merge({
          "GORILLA_CUSTOMER_SECRET_STORE_AZ_CONFIG_VAULT_URI" = module.vault.vault.vault_uri,
          "GORILLA_CUSTOMER_SECRET_STORE_SOURCE"              = "az-secretmanager://wandb",
        }, var.app_wandb_env)
        pod = {
          labels = { "azure.workload.identity/use" = "true" }
        }
        serviceAccount = {
          name        = local.service_account_name
          annotations = { "azure.workload.identity/client-id" = module.identity.identity.client_id }
          labels      = { "azure.workload.identity/use" = "true" }
        }
      }

      ingress = {
        // TODO: For now we will use the existing issuer. We can move this into
        // the operator after testing. Trying to reduce the diff.
        issuer = { create = false }

        annotations = var.use_nginx && var.nginx_controller ? {
          "kubernetes.io/ingress.class"         = "nginx"
          "cert-manager.io/cluster-issuer"      = "cert-issuer"
          "cert-manager.io/acme-challenge-type" = "http01"
        } : {
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
        extraEnv = var.weave_wandb_env
      }

      mysql = { install = false }
      redis = { install = false }

      parquet = {
        extraEnv = var.parquet_wandb_env
      }
    }
  }
}
