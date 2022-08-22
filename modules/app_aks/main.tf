resource "azurerm_kubernetes_cluster" "default" {
  name                = "${var.namespace}-cluster"
  location            = var.location
  resource_group_name = var.resource_group.name
  dns_prefix          = var.namespace

  automatic_channel_upgrade         = "stable"
  role_based_access_control_enabled = true
  http_application_routing_enabled  = false

  ingress_application_gateway {
    gateway_id = var.gateway.id
  }

  default_node_pool {
    name                = "default"
    node_count          = 2
    vm_size             = "Standard_D4s_v3"
    vnet_subnet_id      = var.cluster_subnet_id
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = false
    zones               = ["1", "2"]
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
  }

  tags = var.tags
}

# resource "azurerm_role_assignment" "storage" {
#   scope                = var.storage_account.id
#   role_definition_name = "Storage Blob Data Owner"
#   principal_id         = azurerm_kubernetes_cluster.default.identity.0.principal_id
# }

# resource "azurerm_role_assignment" "storage2" {
#   scope                = var.storage_account.id
#   role_definition_name = "Storage Blob Data Owner"
#   principal_id         = azurerm_kubernetes_cluster.default.kubelet_identity.0.object_id
# }

locals {
  ingress_gateway_principal_id = azurerm_kubernetes_cluster.default.ingress_application_gateway.0.ingress_application_gateway_identity.0.object_id
}

resource "azurerm_role_assignment" "contributor" {
  scope                = var.gateway.id
  role_definition_name = "Contributor"
  principal_id         = local.ingress_gateway_principal_id
}

resource "azurerm_role_assignment" "reader" {
  scope                = var.resource_group.id
  role_definition_name = "Reader"
  principal_id         = local.ingress_gateway_principal_id
}
