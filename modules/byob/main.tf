module "storage" {
  source = "../storage"

  create_queue = false
  namespace    = var.prefix

  deletion_protection = var.deletion_protection
}