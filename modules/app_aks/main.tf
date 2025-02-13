resource "azurerm_kubernetes_cluster" "default" {
  name                = "${var.namespace}-cluster"
  location            = var.location
  resource_group_name = var.resource_group.name
  dns_prefix          = var.namespace
  sku_tier            = var.sku_tier

  automatic_channel_upgrade         = "stable"
  role_based_access_control_enabled = true
  http_application_routing_enabled  = false

  azure_policy_enabled      = true
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  ingress_application_gateway {
    gateway_id = var.gateway.id
  }

  default_node_pool {
    enable_auto_scaling         = true
    max_pods                    = var.max_pods
    name                        = "default"
    node_count                  = var.node_pool_min_vm_per_az
    max_count                   = var.node_pool_max_vm_per_az
    min_count                   = var.node_pool_min_vm_per_az
    temporary_name_for_rotation = "rotating"
    type                        = "VirtualMachineScaleSets"
    vm_size                     = var.node_pool_vm_size
    vnet_subnet_id              = var.cluster_subnet_id
    zones                       = [ var.node_pool_zones[0] ]
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [var.identity.id]
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [microsoft_defender, default_node_pool.0.node_count]
  }

  key_management_service {
    key_vault_key_id = var.etcd_key_vault_key_id
  }
}

locals {
  additonal_zones = slice(var.node_pool_zones, 1, length(var.node_pool_zones))
}

resource "azurerm_kubernetes_cluster_node_pool" "additional" {
  count                       = length(local.additonal_zones)
  kubernetes_cluster_id       = azurerm_kubernetes_cluster.default.id
  enable_auto_scaling         = true
  max_pods                    = var.max_pods
  name                        = "zone${local.additonal_zones[count.index]}"
  node_count                  = var.node_pool_min_vm_per_az
  max_count                   = var.node_pool_max_vm_per_az
  min_count                   = var.node_pool_min_vm_per_az
  vm_size                     = var.node_pool_vm_size
  vnet_subnet_id              = var.cluster_subnet_id
  zones                       = [ local.additonal_zones[count.index] ]

  lifecycle {
    ignore_changes = [node_count]
  }
}

locals {
  ingress_gateway_principal_id = azurerm_kubernetes_cluster.default.ingress_application_gateway.0.ingress_application_gateway_identity.0.object_id

}

resource "azurerm_role_assignment" "gateway" {
  depends_on           = [local.ingress_gateway_principal_id]
  scope                = var.gateway.id
  role_definition_name = "Contributor"
  principal_id         = local.ingress_gateway_principal_id
}

resource "azurerm_role_assignment" "resource_group" {
  depends_on           = [local.ingress_gateway_principal_id]
  scope                = var.resource_group.id
  role_definition_name = "Reader"
  principal_id         = local.ingress_gateway_principal_id
}

resource "azurerm_role_assignment" "public_subnet" {
  depends_on           = [local.ingress_gateway_principal_id]
  scope                = var.public_subnet.id
  role_definition_name = "Contributor"
  principal_id         = local.ingress_gateway_principal_id
}