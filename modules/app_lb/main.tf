resource "azurerm_public_ip" "default" {
  name                = "${var.namespace}-public-ip"
  resource_group_name = var.resource_group.name
  location            = var.location
  sku                 = "Standard"
  allocation_method   = "Static"
  domain_name_label   = var.namespace
  tags                = var.tags
}

locals {
  backend_address_pool_name      = "${var.network.name}-beap"
  frontend_port_name             = "${var.network.name}-feport"
  frontend_ip_configuration_name = "${var.network.name}-feip"
  gateway_ip_configuration_name  = "${var.network.name}-gwip"
  http_setting_name              = "${var.network.name}-be-htst"
  listener_name                  = "${var.network.name}-httplstn"
  request_routing_rule_name      = "${var.network.name}-rqrt"
  redirect_configuration_name    = "${var.network.name}-rdrcfg"
}

resource "azurerm_application_gateway" "default" {
  name                = "${var.namespace}-ag"
  resource_group_name = var.resource_group.name
  location            = var.location

  tags = var.tags

  # identity {
  #   type         = "UserAssigned"
  #   identity_ids = [azurerm_user_assigned_identity.default.id]
  # }

  sku {
    name = "Standard_v2"
    tier = "Standard_v2"
  }

  autoscale_configuration {
    min_capacity = 2
    max_capacity = 5
  }

  gateway_ip_configuration {
    name      = local.gateway_ip_configuration_name
    subnet_id = var.public_subnet.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_port {
    name = "https"
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.default.id
  }

  frontend_ip_configuration {
    name                            = "${local.frontend_ip_configuration_name}-private"
    subnet_id                       = var.public_subnet.id
    private_ip_address_allocation   = "Static"
    private_ip_address              = "10.10.0.10"
    private_link_configuration_name = var.private_link ? "${var.namespace}-private-link" : null
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
    priority                   = 1
  }

  dynamic "private_link_configuration" {
    for_each = var.private_link == true ? [1] : []
    content {
      name = "${var.namespace}-private-link"

      ip_configuration {
        name                          = "primary"
        subnet_id                     = var.private_subnet
        private_ip_address_allocation = "Dynamic"
        primary                       = true
      }
    }
  }

  dynamic "http_listener" {
    for_each = var.private_link == true ? [1] : []
    content {
      name                           = "${local.listener_name}-private"
      frontend_ip_configuration_name = "${local.frontend_ip_configuration_name}-private"
      frontend_port_name             = local.frontend_port_name
      protocol                       = "Http"
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.private_link == true ? [1] : []
    content {
      name                       = "${local.request_routing_rule_name}-${request_routing_rule.key}"
      rule_type                  = "Basic"
      http_listener_name         = "${local.listener_name}-private"
      backend_address_pool_name  = local.backend_address_pool_name
      backend_http_settings_name = local.http_setting_name
      priority                   = "2"
    }
  }

  lifecycle {
    # K8S will be changing all of these settings so we ignore them.
    # We really only needed this resource to assign a known public IP.
    ignore_changes = [
      ssl_certificate,
      request_routing_rule,
      probe,
      url_path_map,
      frontend_port,
      http_listener,
      backend_http_settings,
      backend_address_pool,
      private_link_configuration,
      tags
    ]
  }
}
