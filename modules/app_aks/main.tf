locals {
    k8s_gateway_subnet_name = "${var.namespace}-k8s-subnet"
}

data "azurerm_resource_group" "wandb" {
    name  = "${var.namespace}"
}

data "azurerm_virtual_network" "wandb" {
  resource_group_name = data.azurerm_resource_group.wandb.name
  name                = "${var.namespace}-vnet"
}

data "azurerm_subnet" "backend" {
  name                 = local.k8s_gateway_subnet_name
  virtual_network_name = data.azurerm_virtual_network.wandb.name
  resource_group_name  = data.azurerm_resource_group.wandb.name
}

data "azurerm_application_gateway" "wandb" {
    name                = "wandb-appgateway"
    resource_group_name = data.azurerm_resource_group.wandb.name
}

resource "azurerm_kubernetes_cluster" "wandb" {
  name                = "${var.namespace}-k8s"
  location            = data.azurerm_resource_group.wandb.location
  resource_group_name = data.azurerm_resource_group.wandb.name
  dns_prefix          = var.namespace

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = "Standard_D2s_v4"
    vnet_subnet_id = data.azurerm_subnet.backend.id
    type           = "VirtualMachineScaleSets"
    # zones          = ["1", "2"] #TODO: Uncomment after testing
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    # TODO: output firewall?
    # load_balancer_profile {
    #   outbound_ip_address_ids = ["${azurerm_public_ip.outbound.id}"]
    # }
  }

  # TODO: RBAC?
  identity {
    type = "SystemAssigned"
  }

  http_application_routing_enabled = false

  ingress_application_gateway {
    gateway_id = data.azurerm_application_gateway.wandb.id
  }
  
  automatic_channel_upgrade = "stable"

  private_cluster_enabled = var.kubernetes_api_is_private

  depends_on = [
    data.azurerm_virtual_network.wandb,
    data.azurerm_application_gateway.wandb,
  ]
}

data "azurerm_kubernetes_cluster" "wandb" {
  depends_on          = [azurerm_kubernetes_cluster.wandb]
  name                = azurerm_kubernetes_cluster.wandb.name
  resource_group_name = data.azurerm_resource_group.wandb.name
}
