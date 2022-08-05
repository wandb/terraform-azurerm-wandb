
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

  database_version             = var.database_version
  database_private_dns_zone_id = module.networking.database_private_dns_zone.id
  database_subnet_id           = module.networking.database_subnet.id

  tags = var.tags
}

module "app_aks" {
  source              = "./modules/app_aks"
  namespace           = var.namespace
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location

  cluster_subnet_id = module.networking.private_subnet.id

  tags = var.tags
}

module "storage" {
  source = "./modules/storage"

  namespace           = var.namespace
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location

  tags = var.tags
}

# module "aks_app" {
#   source  = "wandb/wandb/kubernetes"
#   version = "1.1.2"

#   license = var.license

#   host                       = local.url
#   bucket                     = "gs://${local.bucket}"
#   bucket_queue               = local.bucket_queue
#   database_connection_string = "mysql://${module.database.connection_string}"
#   redis_connection_string    = local.redis_connection_string
#   redis_ca_cert              = local.redis_certificate

#   oidc_client_id   = var.oidc_client_id
#   oidc_issuer      = var.oidc_issuer
#   oidc_auth_method = var.oidc_auth_method

#   wandb_image   = var.wandb_image
#   wandb_version = var.wandb_version

#   # If we dont wait, tf will start trying to deploy while the work group is
#   # still spinning up
#   depends_on = [
#     module.database,
#     module.redis,
#     module.storage,
#     module.app_aks
#   ]
# }