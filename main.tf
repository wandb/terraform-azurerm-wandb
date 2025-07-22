locals {
  fqdn       = var.subdomain == null ? var.domain_name : "${var.subdomain}.${var.domain_name}"
  url_prefix = var.ssl ? "https" : "http"
  url        = "${local.url_prefix}://${local.fqdn}"

  redis_capacity             = coalesce(var.redis_capacity, local.deployment_size[var.size].cache)
  database_sku_name          = coalesce(var.database_sku_name, local.deployment_size[var.size].db)
  kubernetes_instance_type   = coalesce(var.kubernetes_instance_type, local.deployment_size[var.size].node_instance)
  kubernetes_min_node_per_az = coalesce(var.kubernetes_min_node_per_az, local.deployment_size[var.size].min_node_count)
  kubernetes_max_node_per_az = coalesce(var.kubernetes_max_node_per_az, local.deployment_size[var.size].max_node_count)
}

resource "azurerm_resource_group" "default" {
  name     = var.namespace
  location = var.location

  tags = var.tags
}

module "identity" {
  source         = "./modules/identity"
  namespace      = var.namespace
  otel_identity  = var.azuremonitor
  resource_group = azurerm_resource_group.default
  location       = azurerm_resource_group.default.location
}

module "networking" {
  source              = "./modules/networking"
  namespace           = var.namespace
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  private_link        = var.create_private_link
  allowed_ip_ranges   = var.allowed_ip_ranges
  tags                = var.tags
}

module "database" {
  source    = "./modules/database"
  namespace = var.namespace

  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location

  database_availability_mode   = var.database_availability_mode
  database_version             = var.database_version
  database_private_dns_zone_id = module.networking.database_private_dns_zone.id
  database_subnet_id           = module.networking.database_subnet.id
  sku_name                     = local.database_sku_name
  deletion_protection          = var.deletion_protection
  slow_query_log_enabled       = var.slow_query_log_enabled

  database_key_id = try(module.vault.vault_internal_keys[module.vault.vault_key_map.database].id, null)
  identity_ids    = module.identity.identity.id
  tags            = var.tags

  depends_on = [module.networking]
}

moved {
  from = module.redis.azurerm_redis_cache.default
  to   = module.redis[0].azurerm_redis_cache.default
}

module "redis" {
  source              = "./modules/redis"
  count               = var.create_redis ? 1 : 0
  namespace           = var.namespace
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  capacity            = local.redis_capacity
  depends_on          = [module.networking]

  tags = var.tags
}

module "vault" {
  source = "./modules/vault"

  identity_object_id = module.identity.identity.principal_id
  location           = azurerm_resource_group.default.location
  namespace          = var.namespace
  resource_group     = azurerm_resource_group.default

  enable_database_vault_key = var.enable_database_vault_key
  enable_storage_vault_key  = var.enable_storage_vault_key

  tags = var.tags
}

module "storage" {
  source = "./modules/storage"

  count               = 1
  namespace           = var.namespace
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  create_queue        = !var.use_internal_queue
  identity_ids        = module.identity.identity.id
  deletion_protection = var.deletion_protection

  storage_key_id               = try(module.vault.vault_internal_keys[module.vault.vault_key_map.storage].id, null)
  disable_storage_vault_key_id = var.disable_storage_vault_key_id

  tags = var.tags
}

module "app_lb" {
  source = "./modules/app_lb"

  namespace      = var.namespace
  resource_group = azurerm_resource_group.default
  location       = azurerm_resource_group.default.location
  network        = module.networking.network
  public_subnet  = module.networking.public_subnet
  private_subnet = module.networking.private_subnet
  private_link   = var.create_private_link

  tags = var.tags
}

data "azapi_resource_list" "az_zones" {
  parent_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
  type      = "Microsoft.Compute/skus@2021-07-01"

  response_export_values = ["value"]
}

locals {
  vm_skus = [
    for sku in jsondecode(data.azapi_resource_list.az_zones.output).value :
    sku if(
      sku.resourceType == "virtualMachines" &&
      lower(sku.locations[0]) == lower(azurerm_resource_group.default.location) &&
      sku.name == local.kubernetes_instance_type
    )
  ]

  num_zones        = var.node_pool_zones != null ? length(var.node_pool_zones) : var.node_pool_num_zones
  restricted_zones = length(local.vm_skus[0].restrictions) > 0 ? local.vm_skus[0].restrictions[0].restrictionInfo.zones : []
  all_zones        = local.vm_skus[0].locationInfo[0].zones
  valid_zones      = setsubtract(local.all_zones, local.restricted_zones)
  node_pool_zones  = var.node_pool_zones != null ? var.node_pool_zones : slice(sort(local.valid_zones), 0, local.num_zones)
}

module "app_aks" {
  source     = "./modules/app_aks"
  depends_on = [module.app_lb]

  cluster_subnet_id       = module.networking.private_subnet.id
  etcd_key_vault_key_id   = module.vault.etcd_key_id
  gateway                 = module.app_lb.gateway
  identity                = module.identity.identity
  location                = azurerm_resource_group.default.location
  namespace               = var.namespace
  node_pool_min_vm_per_az = local.kubernetes_min_node_per_az
  node_pool_max_vm_per_az = local.kubernetes_max_node_per_az
  node_pool_vm_size       = local.kubernetes_instance_type
  node_pool_zones         = local.node_pool_zones
  public_subnet           = module.networking.public_subnet
  resource_group          = azurerm_resource_group.default
  sku_tier                = var.cluster_sku_tier
  tags                    = merge(var.tags, { cache_size = var.cache_size }, var.kubernetes_cluster_tags)
}
locals {
  service_account_name         = "wandb-app"
  private_endpoint_approval_sa = "private-endpoint-sa"
  otel_sa_name                 = "wandb-otel-daemonset"
}

resource "azurerm_federated_identity_credential" "app" {
  parent_id           = module.identity.identity.id
  name                = "${var.namespace}-app-credentials"
  resource_group_name = azurerm_resource_group.default.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = module.app_aks.oidc_issuer_url
  subject             = "system:serviceaccount:default:${local.service_account_name}"
}



module "service_accounts" {
  source = "./modules/secure_storage_connector/service_accounts"
}

locals {
  k8s_sa_map = module.service_accounts.k8s_sa_map
}

resource "azurerm_federated_identity_credential" "sa_map" {
  for_each            = local.k8s_sa_map
  parent_id           = module.identity.identity.id
  name                = "${var.namespace}-federated-credential-${each.value}"
  resource_group_name = azurerm_resource_group.default.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = module.app_aks.oidc_issuer_url
  subject             = "system:serviceaccount:default:${each.value}"
}

# aks workload identity resources for private endpoint approval application
module "pod_identity" {
  count          = length(var.allowed_subscriptions) > 0 ? 1 : 0
  source         = "./modules/identity"
  depends_on     = [module.app_aks]
  namespace      = "${var.namespace}-private-endpoint-pod"
  resource_group = azurerm_resource_group.default
  location       = azurerm_resource_group.default.location
}

resource "azurerm_federated_identity_credential" "pod" {
  count               = length(var.allowed_subscriptions) > 0 ? 1 : 0
  parent_id           = module.pod_identity[0].identity.id
  name                = "${var.namespace}-app-credentials"
  resource_group_name = azurerm_resource_group.default.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = module.app_aks.oidc_issuer_url
  subject             = "system:serviceaccount:default:${local.private_endpoint_approval_sa}"

}

resource "azurerm_role_assignment" "gateway_role" {
  count                = length(var.allowed_subscriptions) > 0 ? 1 : 0
  scope                = module.app_lb.gateway.id
  role_definition_name = "Contributor"
  principal_id         = module.pod_identity[0].identity.principal_id

}

module "cron_job" {
  count  = length(var.allowed_subscriptions) > 0 ? 1 : 0 # private endpoint approval application deployed as a cronjob in default namespace
  source = "./modules/cron_job"

  namespace              = "default"
  client_id              = module.pod_identity[0].identity.client_id
  serviceaccountName     = local.private_endpoint_approval_sa
  subscriptionId         = data.azurerm_subscription.current.subscription_id
  resourceGroupName      = azurerm_resource_group.default.name
  applicationGatewayName = module.app_lb.gateway.name
  allowedSubscriptions   = var.allowed_subscriptions
  depends_on             = [module.app_lb, module.pod_identity]
}

resource "azurerm_role_assignment" "otel_role" {
  count                = var.azuremonitor ? 1 : 0
  scope                = azurerm_resource_group.default.id
  role_definition_name = "Contributor"
  principal_id         = module.identity.otel_identity.principal_id
}

resource "azurerm_federated_identity_credential" "otel_app" {
  count               = var.azuremonitor ? 1 : 0
  parent_id           = module.identity.otel_identity.id
  name                = "${var.namespace}-otel-app-credentials"
  resource_group_name = azurerm_resource_group.default.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = module.app_aks.oidc_issuer_url
  subject             = "system:serviceaccount:default:${local.otel_sa_name}"
}

module "cert_manager" {
  # if use_dns_resolver is set then disable our default install of cert_manager
  count = var.use_dns_resolver ? 0 : 1

  source    = "./modules/cert_manager"
  namespace = var.namespace

  ingress_class              = "azure/application-gateway"
  cert_manager_email         = "sysadmin@wandb.com"
  cert_manager_chart_version = "v1.9.1"
  tags                       = var.tags

  depends_on = [module.app_aks]
}

moved {
  from = module.cert_manager
  to   = module.cert_manager[0]
}

module "clickhouse" {
  count               = var.clickhouse_private_endpoint_service_name != "" ? 1 : 0
  source              = "./modules/clickhouse"
  namespace           = var.namespace
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  network_id          = module.networking.network.id
  private_subnet_id   = module.networking.private_subnet.id

  clickhouse_private_endpoint_service_name = var.clickhouse_private_endpoint_service_name
  clickhouse_region                        = var.clickhouse_region
}

locals {
  use_customer_bucket = (
    var.storage_account != "" &&
    var.blob_container != "" &&
    var.storage_key != ""
  )
  default_bucket_config = {
    provider  = "az"
    name      = var.storage_account
    path      = "${var.blob_container}/${var.bucket_path}"
    accessKey = var.storage_key
  }

  bucket_config                    = var.external_bucket != null ? var.external_bucket : (local.use_customer_bucket ? local.default_bucket_config : null)
  weave_trace_service_account_name = "wandb-weave-trace"

  ctrlplane_redis_host = "redis.redis.svc.cluster.local"
  ctrlplane_redis_port = "26379"
  ctrlplane_redis_params = {
    master = "gorilla"
  }
  spec = {
    values = {
      global = {
        size          = var.size
        host          = local.url
        license       = var.license
        cloudProvider = "azure"
        bucket        = local.bucket_config == null ? {} : local.bucket_config
        defaultBucket = {
          provider  = "az"
          name      = module.storage[0].account.name
          path      = "${module.storage[0].container.name}/${var.bucket_path}"
          accessKey = module.storage[0].account.primary_access_key
        }
        azureIdentityForBucket = {
          clientID = module.identity.identity.client_id
          tenantID = module.identity.identity.tenant_id
        }

        mysql = {
          host     = module.database.address
          database = module.database.database_name
          user     = module.database.username
          password = module.database.password
          port     = 3306
        }

        redis = var.use_ctrlplane_redis ? {
          host     = local.ctrlplane_redis_host
          password = ""
          port     = local.ctrlplane_redis_port
          params   = local.ctrlplane_redis_params
          external = true
          } : var.use_external_redis ? {
          host     = var.external_redis_host
          password = ""
          port     = var.external_redis_port
          params   = var.external_redis_params
          external = true
          } : var.create_redis ? {
          host     = module.redis[0].instance.hostname
          password = module.redis[0].instance.primary_access_key
          port     = module.redis[0].instance.port
          params = {
            master = ""
          }
          external = false
          } : {
          host     = ""
          password = ""
          port     = ""
          params = {
            master = ""
          }
          external = false
        }

        extraEnv = merge({
          "GORILLA_CUSTOMER_SECRET_STORE_AZ_CONFIG_VAULT_URI" = module.vault.vault.vault_uri,
          "GORILLA_CUSTOMER_SECRET_STORE_SOURCE"              = "az-secretmanager://wandb",
        }, var.other_wandb_env)
      }

      app = {
        # Parts of the helm chart use pod label patterns with different patterns.
        # The following is done to support both patterns.
        pod = {
          labels = { "azure.workload.identity/use" = "true" }
        }
        podLabels = { "azure.workload.identity/use" = "true" }
        serviceAccount = {
          name        = local.service_account_name
          annotations = { "azure.workload.identity/client-id" = module.identity.identity.client_id }
          labels      = { "azure.workload.identity/use" = "true" }
        }
        internalJWTMap = [
          {
            subject = "system:serviceaccount:default:${local.weave_trace_service_account_name}",
            issuer  = module.app_aks.oidc_issuer_url
          }
        ]
      }

      api = {
        serviceAccount = {
          name        = local.k8s_sa_map.api
          annotations = { "azure.workload.identity/client-id" = module.identity.identity.client_id }
          labels      = { "azure.workload.identity/use" = "true" }
        }
        pod = {
          labels = { "azure.workload.identity/use" = "true" }
        }
        podLabels = { "azure.workload.identity/use" = "true" }
      }

      console = {
        extraEnv = {
          "BUCKET_ACCESS_IDENTITY" = "CLIENT_ID=${module.identity.identity.client_id} - TENANT_ID=${module.identity.identity.tenant_id} - OIDC_ISSUER_URL=${module.app_aks.oidc_issuer_url}"
        }
        serviceAccount = {
          name        = local.k8s_sa_map.console
          annotations = { "azure.workload.identity/client-id" = module.identity.identity.client_id }
          labels      = { "azure.workload.identity/use" = "true" }
        }
        pod = {
          labels = { "azure.workload.identity/use" = "true" }
        }
        podLabels = { "azure.workload.identity/use" = "true" }
      }

      ingress = {
        issuer = { create = false }
        annotations = {
          "kubernetes.io/ingress.class"                 = "azure/application-gateway"
          "cert-manager.io/cluster-issuer"              = "cert-issuer"
          "cert-manager.io/acme-challenge-type"         = var.use_dns_resolver ? "dns01" : "http01"
          "appgw.ingress.kubernetes.io/request-timeout" = "300"
        }

        labels = var.create_private_link ? {
            "sha_hash" = substr(sha256("yes"), 0, 50)
          } : {}

        tls = [
          { hosts = [trimprefix(trimprefix(local.url, "https://"), "http://")], secretName = "wandb-ssl-cert" }
        ]
        ## In order to support secondary ingress required min version 0.13.0 of operator-wandb chart
        secondary = {
          create       = var.create_private_link
          nameOverride = "${var.namespace}-private-ingress"
          annotations = {
            "kubernetes.io/ingress.class"                   = "azure/application-gateway"
            "appgw.ingress.kubernetes.io/request-timeout" = "300"
            "appgw.ingress.kubernetes.io/use-private-ip" : "true"
          }
          tls = [
            { hosts = [trimprefix(trimprefix(local.url, "https://"), "http://")], secretName = "wandb-ssl-cert" }
          ]
        }
      }
 

      otel = {
        daemonset = var.azuremonitor ? {
          pod            = { labels = { "azure.workload.identity/use" = "true" } }
          serviceAccount = { annotations = { "azure.workload.identity/client-id" = module.identity.otel_identity.client_id } }
          config = {
            receivers = {
              azuremonitor = {
                subscription_id      = data.azurerm_subscription.current.subscription_id
                resource_groups      = [var.namespace]
                auth                 = "workload_identity"
                tenant_id            = "$${env:AZURE_TENANT_ID}"
                client_id            = "$${env:AZURE_CLIENT_ID}"
                federated_token_file = "$${env:AZURE_FEDERATED_TOKEN_FILE}"
                services             = ["Microsoft.DBforMySQL/flexibleServers", "Microsoft.Cache/Redis"]
              }
            }
            service = {
              pipelines = {
                metrics = {
                  receivers = ["hostmetrics", "k8s_cluster", "kubeletstats", "azuremonitor"]
                }
              }
            }
          }
          } : {
          pod            = {}
          serviceAccount = {}
          config = {
            receivers = {}
            service   = {}
          }
        }
      }

      weave = {
        serviceAccount = {
          name        = local.k8s_sa_map.weave
          annotations = { "azure.workload.identity/client-id" = module.identity.identity.client_id }
          labels      = { "azure.workload.identity/use" = "true" }
        }
        persistence = {
          provider = "azurefile"
        }
        pod = {
          labels = { "azure.workload.identity/use" = "true" }
        }
        podLabels = { "azure.workload.identity/use" = "true" }
      }

      weave-trace = {
        serviceAccount = {
          name        = local.k8s_sa_map.weaveTrace
          annotations = { "azure.workload.identity/client-id" = module.identity.identity.client_id }
          labels      = { "azure.workload.identity/use" = "true" }
        }
        pod = {
          labels = { "azure.workload.identity/use" = "true" }
        }
        podLabels = { "azure.workload.identity/use" = "true" }
      }

      bufstream = {
        serviceAccount = {
          name        = local.k8s_sa_map.bufstream
          annotations = { "azure.workload.identity/client-id" = module.identity.identity.client_id }
          labels      = { "azure.workload.identity/use" = "true" }
        }
        pod = {
          labels = { "azure.workload.identity/use" = "true" }
        }
        podLabels = { "azure.workload.identity/use" = "true" }
      }



      mysql = { install = false }
      redis = { install = false }

      parquet = {
        serviceAccount = {
          name        = local.k8s_sa_map.parquet
          annotations = { "azure.workload.identity/client-id" = module.identity.identity.client_id }
          labels      = { "azure.workload.identity/use" = "true" }
        }
        pod = {
          labels = { "azure.workload.identity/use" = "true" }
        }
        podLabels = { "azure.workload.identity/use" = "true" }
        extraEnv  = var.parquet_wandb_env
      }

      executor = {
        serviceAccount = {
          name        = local.k8s_sa_map.executor
          annotations = { "azure.workload.identity/client-id" = module.identity.identity.client_id }
          labels      = { "azure.workload.identity/use" = "true" }
        }
        pod = {
          labels = { "azure.workload.identity/use" = "true" }
        }
        podLabels = { "azure.workload.identity/use" = "true" }
      }

      settingsMigrationJob = {
        serviceAccount = {
          name        = local.k8s_sa_map.settingsMigrationJob
          annotations = { "azure.workload.identity/client-id" = module.identity.identity.client_id }
          labels      = { "azure.workload.identity/use" = "true" }
        }
        pod = {
          labels = { "azure.workload.identity/use" = "true" }
        }
        podLabels = { "azure.workload.identity/use" = "true" }
      }

      glue = {
        serviceAccount = {
          name        = local.k8s_sa_map.glue
          annotations = { "azure.workload.identity/client-id" = module.identity.identity.client_id }
          labels      = { "azure.workload.identity/use" = "true" }
        }
        pod = {
          labels = { "azure.workload.identity/use" = "true" }
        }
        podLabels = { "azure.workload.identity/use" = "true" }
      }

      filestream = {
        serviceAccount = {
          name        = local.k8s_sa_map.filestream
          annotations = { "azure.workload.identity/client-id" = module.identity.identity.client_id }
          labels      = { "azure.workload.identity/use" = "true" }
        }
        pod = {
          labels = { "azure.workload.identity/use" = "true" }
        }
        podLabels = { "azure.workload.identity/use" = "true" }
      }

      filemeta = {
        serviceAccount = {
          name        = local.k8s_sa_map.filemeta
          annotations = { "azure.workload.identity/client-id" = module.identity.identity.client_id }
          labels      = { "azure.workload.identity/use" = "true" }
        }
      }
      pod = {
        labels = { "azure.workload.identity/use" = "true" }
      }
      podLabels = { "azure.workload.identity/use" = "true" }

    }
  }
}

module "wandb" {
  source  = "wandb/wandb/helm"
  version = "3.0.0"

  spec = local.spec

  depends_on = [
    module.app_aks,
    module.cert_manager,
    module.database,
    module.storage,
    module.redis,
  ]
  operator_chart_version = var.operator_chart_version
  controller_image_tag   = var.controller_image_tag
  enable_helm_operator   = var.enable_helm_operator
  enable_helm_wandb      = var.enable_helm_wandb
}
