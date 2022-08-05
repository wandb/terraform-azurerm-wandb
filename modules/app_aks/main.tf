resource "azurerm_kubernetes_cluster" "default" {
  name                = "${var.namespace}-cluster"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.namespace

  automatic_channel_upgrade         = "stable"
  role_based_access_control_enabled = true

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
    load_balancer_sku = "standard"
  }

  tags = var.tags
}
