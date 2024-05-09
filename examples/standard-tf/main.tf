provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

data "azurerm_subscription" "current" {}

provider "kubernetes" {
  host                   = module.wandb.cluster_host
  cluster_ca_certificate = base64decode(module.wandb.cluster_ca_certificate)
  client_key             = base64decode(module.wandb.cluster_client_key)
  client_certificate     = base64decode(module.wandb.cluster_client_certificate)
}

provider "helm" {
  kubernetes {
    host                   = module.wandb.cluster_host
    cluster_ca_certificate = base64decode(module.wandb.cluster_ca_certificate)
    client_key             = base64decode(module.wandb.cluster_client_key)
    client_certificate     = base64decode(module.wandb.cluster_client_certificate)
  }
}

# Spin up all required services
module "wandb" {
  source = "../../"

  namespace   = var.namespace
  location    = var.location
  license     = var.license

  domain_name = var.domain_name
  subdomain   = var.subdomain

  wandb_version = var.wandb_version
  wandb_image   = var.wandb_image

  database_sku_name = var.database_sku_name
  database_version = var.database_version

  create_redis       = true
  use_internal_queue = true
  ssl = var.ssl
  deletion_protection = true
  kubernetes_node_count = var.kubernetes_node_count
  
  storage_account = var.storage_account
  blob_container = var.blob_container
  storage_key = var.storage_key
  external_bucket  = var.external_bucket

  weave_wandb_env = var.weave_wandb_env
  app_wandb_env = var.app_wandb_env
  parquet_wandb_env = var.parquet_wandb_env

  tags = var.tags
}


