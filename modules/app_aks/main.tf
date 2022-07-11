resource "azurerm_kubernetes_cluster" "default" {
  name                = "${var.namespace}-cluster"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.namespace

  automatic_channel_upgrade = "stable"
}