module "storage" {
  source = "../storage"

  create_queue        = false
  namespace           = var.prefix
  resource_group_name = var.resource_group_name
  location            = var.location

  deletion_protection = var.deletion_protection

  principal_id = var.managed_identity_principal_id
}
