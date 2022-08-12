resource "azurerm_public_ip" "default" {
  name                = "${var.namespace}-public-ip"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  allocation_method   = "Static"
  domain_name_label   = var.namespace
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
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = var.tags

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

  lifecycle {
    # K8S will be changing all of these settings so we ignore them.
    # We really only needed this resource to assign a known public IP.
    ignore_changes = [
      ssl_certificate,
      request_routing_rule,
      probe,
      frontend_port,
      http_listener,
      backend_http_settings,
      backend_address_pool,
      tags
    ]
  }
}

locals {
  deployment_is_private = false
  ssl_certificate_name  = null
  tls_secret_name       = "wandb-ssl-cert"
  host                  = var.fqdn
  service_name          = "wandb"
  service_port          = 80
}

resource "kubernetes_ingress" "default" {
  count                  = var.create_kubernetes_ingress ? 1 : 0
  wait_for_load_balancer = true
  metadata {
    name = "wandb"
    annotations = {
      "kubernetes.io/ingress.class"                       = "azure/application-gateway"
      "appgw.ingress.kubernetes.io/appgw-ssl-certificate" = local.ssl_certificate_name
      "appgw.ingress.kubernetes.io/use-private-ip"        = local.deployment_is_private ? "true" : null
      "cert-manager.io/cluster-issuer"                    = local.deployment_is_private ? null : "cert-issuer"
      "cert-manager.io/acme-challenge-type"               = local.deployment_is_private ? null : "http01"
    }
  }
  spec {
    tls {
      hosts       = local.deployment_is_private ? null : [local.host]
      secret_name = local.deployment_is_private ? null : local.tls_secret_name
    }
    rule {
      http {
        path {
          path = "/"
          backend {
            service_name = local.service_name
            service_port = local.service_port
          }
        }
      }
    }
    rule {
      host = local.host
      http {
        path {
          path = "/"
          backend {
            service_name = local.service_name
            service_port = local.service_port
          }
        }
      }
    }
  }
}

