provider "azurerm" {
  features {}
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
}
