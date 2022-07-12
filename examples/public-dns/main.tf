provider "azurerm" {
  features {}
}

# provider "kubernetes" {
#   host                   = module.wandb.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.wandb.cluster_ca_certificate)
#   client_key             = base64decode(module.wandb.cluster_client_key)
#   client_certificate     = base64decode(module.wandb.cluster_client_certificate)
# }

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

  create_redis       = true
  use_internal_queue = true

  deletion_protection = false

  tags = {
    "Example" : "PublicDns"
  }
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
