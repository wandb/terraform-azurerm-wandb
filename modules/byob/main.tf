
module "storage" {
  source       = "../storage"
  create_queue = false
  namespace    = var.prefix
}