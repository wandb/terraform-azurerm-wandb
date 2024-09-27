terraform {
  required_version = "~> 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.17"
    }
    azapi = {
      source = "azure/azapi"
      version = "~> 1.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.6"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

provider "azapi" {
  subscription_id = var.subscription_id
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

  database_sku_name = var.database_sku_name

  wandb_version = var.wandb_version
  wandb_image   = var.wandb_image

  create_redis       = true
  use_internal_queue = true

  deletion_protection = false

  bucket_path = var.bucket_path

  tags = {
    "Example" : "PublicDns"
  }
  node_pool_num_zones = 2
}

# # You'll want to update your DNS with the provisioned IP address
# output "url" {
#   value = module.wandb.url
# }

# output "address" {
#   value = module.wandb.address
# }

# output "bucket_name" {
#   value = module.wandb.bucket_name
# }
