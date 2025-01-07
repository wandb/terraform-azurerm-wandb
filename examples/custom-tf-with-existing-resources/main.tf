provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}


provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.cluster.kube_config.0.host
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_config.0.cluster_ca_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_config.0.client_key)
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_config.0.client_certificate)
}

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.cluster.kube_config.0.host
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_config.0.cluster_ca_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_config.0.client_key)
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_config.0.client_certificate)
  }
}


locals {
  fqdn           = var.subdomain == null ? var.domain_name : "${var.subdomain}.${var.domain_name}"
  url_prefix     = var.ssl ? "https" : "http"
  url            = "${local.url_prefix}://${local.fqdn}"
  network        = data.azurerm_virtual_network.network
  private_subnet = data.azurerm_subnet.private
  public_subnet  = data.azurerm_subnet.public
  resource_group = data.azurerm_resource_group.group
  vault_uri      = var.vault_uri
  identity_id    = data.azurerm_user_assigned_identity.identity.client_id
}


module "storage" {
  count  = (var.blob_container == "" && var.external_bucket == null) ? 1 : 0
  source = "../../modules/storage"

  namespace           = var.namespace
  resource_group_name = local.resource_group.name
  location            = local.resource_group.location
  create_queue        = !var.use_internal_queue
  deletion_protection = var.deletion_protection

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

  redis_connection_string = "redis://:${var.redis_env.primary_access_key}@${var.redis_env.hostname}:${var.redis_env.port}"
}

locals {
  service_account_name = "wandb-app"
}

resource "azurerm_federated_identity_credential" "app" {
  parent_id           = data.azurerm_user_assigned_identity.identity.id
  name                = "${var.namespace}-app-credentials"
  resource_group_name = local.resource_group.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = data.azurerm_kubernetes_cluster.cluster.oidc_issuer_url
  subject             = "system:serviceaccount:default:${local.service_account_name}"
}

module "cert_manager" {
  source    = "../../modules/cert_manager"
  namespace = var.namespace

  ingress_class              = "azure/application-gateway"
  cert_manager_email         = "sysadmin@wandb.com"
  cert_manager_chart_version = "v1.9.1"
  tags                       = var.tags

  depends_on = [data.azurerm_kubernetes_cluster.cluster]
}

module "wandb" {
  source  = "wandb/wandb/helm"
  version = "2.0.0"

  depends_on = [
    data.azurerm_kubernetes_cluster.cluster,
    module.cert_manager,
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
          host     = var.database_env.host
          database = var.database_env.database_name
          user     = var.database_env.username
          password = var.database_env.password
          port     = 3306
        }

        redis = {
          host     = var.redis_env.hostname
          password = var.redis_env.primary_access_key
          port     = var.redis_env.port
        }

        extraEnv = var.other_wandb_env

      }

      app = {
        extraEnv = merge({
          "GORILLA_CUSTOMER_SECRET_STORE_AZ_CONFIG_VAULT_URI" = local.vault_uri,
          "GORILLA_CUSTOMER_SECRET_STORE_SOURCE"              = "az-secretmanager://wandb",
        }, var.app_wandb_env)
        pod = {
          labels = { "azure.workload.identity/use" = "true" }
        }
        serviceAccount = {
          name        = local.service_account_name
          annotations = { "azure.workload.identity/client-id" = local.identity_id }
          labels      = { "azure.workload.identity/use" = "true" }
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
