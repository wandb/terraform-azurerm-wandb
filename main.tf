locals {
  fqdn = var.subdomain == null ? var.domain_name : "${var.subdomain}.${var.domain_name}"
}

module "storage" {
    count = local.create_bucket ? 1 : 0
    source = "./modules/storage"
    namespace = var.namespace
}