provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "wandb" {
  name     = var.namespace
  location = var.region
}

module "networking" {
    source    = "./modules/networking"
    namespace = var.namespace
    region    = var.region

    create_vnet                   = var.create_vnet
    vpc_cidr_block                = var.vpc_cidr_block
    private_subnet_cidrs          = var.private_subnet_cidrs
    public_subnet_cidrs           = var.public_subnet_cidrs
    use_web_application_firewall  = var.use_web_application_firewall
    firewall_ip_address_allow     = var.firewall_ip_address_allow
    private_ip                    = var.private_ip
    deployment_is_private         = var.deployment_is_private

    depends_on = [
      azurerm_resource_group.wandb
    ]
}

module "database" {
    source = "./modules/database"
    namespace = var.namespace
    region = var.region

    db_admin      = var.db_admin
    db_password   = var.db_password
    mysql_version = var.mysql_version
    
    depends_on = [
      azurerm_resource_group.wandb
    ]
}

module "file_storage" {
    source = "./modules/file_storage"
    namespace = var.namespace
    region = var.region
}
