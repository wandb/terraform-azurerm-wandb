locals {
  backend_address_pool_name      = "${azurerm_virtual_network.wandb.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.wandb.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.wandb.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.wandb.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.wandb.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.wandb.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.wandb.name}-rdrcfg"
  # TODO: this might break if Azure changes the name
  app_gateway_uid_name = "ingressapplicationgateway-${var.namespace}-k8s"
  app_gateway_subnet_name = "${var.namespace}-appgw-subnet"
  k8s_gateway_subnet_name = "${var.namespace}-k8s-subnet"
}

resource "azurerm_resource_group" "wandb" {
  name     = var.namespace
  location = var.region
}

resource "azurerm_virtual_network" "wandb" {
  name                = "${var.namespace}-vpc"
  address_space       = [var.vpc_cidr_block]
  location            = azurerm_resource_group.wandb.location
  resource_group_name = azurerm_resource_group.wandb.name
}

resource "azurerm_subnet" "backend" {
  name                 = local.k8s_gateway_subnet_name
  resource_group_name  = azurerm_resource_group.wandb.name
  virtual_network_name = azurerm_virtual_network.wandb.name
  address_prefixes     = [var.private_subnet_cidrs]

  service_endpoints                              = ["Microsoft.Sql"] # "Microsoft.Storage", "Microsoft.Web"]
  enforce_private_link_endpoint_network_policies = true
  enforce_private_link_service_network_policies  = true
}

resource "azurerm_subnet" "frontend" {
  name                 = local.app_gateway_subnet_name
  resource_group_name  = azurerm_resource_group.wandb.name
  virtual_network_name = azurerm_virtual_network.wandb.name
  address_prefixes     = [var.public_subnet_cidrs]
}

resource "azurerm_public_ip" "wandb" {
  name                = "wandb-public-ip"
  sku                 = "Standard"
  location            = azurerm_resource_group.wandb.location
  resource_group_name = azurerm_resource_group.wandb.name
  allocation_method   = "Static"
  domain_name_label   = var.namespace
}

resource "azurerm_web_application_firewall_policy" "wandb" {
  name                = "wandb-wafpolicy"
  resource_group_name = azurerm_resource_group.wandb.name
  location            = azurerm_resource_group.wandb.location
  tags                = {}

  custom_rules {
    name      = "APIAccessRestrictions"
    priority  = 1
    rule_type = "MatchRule"

    match_conditions {
      transforms = []
      match_variables {
        variable_name = "RemoteAddr"
      }

      operator           = "IPMatch"
      negation_condition = true
      match_values       = length(var.firewall_ip_address_allow) == 0 ? ["10.10.0.0/16"] : var.firewall_ip_address_allow
    }

    match_conditions {
      transforms = []
      match_variables {
        variable_name = "RequestHeaders"
        selector      = "Authorization"
      }

      operator           = "Contains"
      negation_condition = false
      match_values       = ["Basic"]
    }

    action = length(var.firewall_ip_address_allow) == 0 ? "Allow" : "Block"
  }

  policy_settings {
    enabled            = true
    mode               = "Prevention"
    request_body_check = false
  }

  managed_rules {
    managed_rule_set {
      version = "3.2"
      rule_group_override {
        rule_group_name = "REQUEST-942-APPLICATION-ATTACK-SQLI"
        disabled_rules = [
          "942200",
          "942210",
          "942260",
          "942450",
          "942340",
          "942370",
          "942440"
        ]
      }
      rule_group_override {
        rule_group_name = "REQUEST-941-APPLICATION-ATTACK-XSS"
        disabled_rules = [
          "941101",
          "941120"
        ]
      }
      rule_group_override {
        rule_group_name = "REQUEST-920-PROTOCOL-ENFORCEMENT"
        disabled_rules = [
          "920300",
          "920440"
        ]
      }
      rule_group_override {
        rule_group_name = "REQUEST-913-SCANNER-DETECTION"
        disabled_rules = [
          "913101"
        ]
      }
    }
  }
}

resource "azurerm_network_security_group" "wandb" {
  # The AKS Application Gateway ingress controller is only able to use a private IP
  # if the gateway is using Standard_v2 or WAF_v2.  They both currently require
  # a public IP, see: https://github.com/Azure/application-gateway-kubernetes-ingress/issues/741
  # This rule blocks all internet access to the gateway and is only used if
  # var.deployment_is_private
  name                = "wandb-private-deployment-security-group"
  location            = azurerm_resource_group.wandb.location
  resource_group_name = azurerm_resource_group.wandb.name

  security_rule {
    name                       = "asg-required-management-ports"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65200-65535"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "wandb" {
  count                     = var.deployment_is_private ? 1 : 0
  subnet_id                 = azurerm_subnet.frontend.id
  network_security_group_id = azurerm_network_security_group.wandb.id
}

resource "azurerm_application_gateway" "wandb" {
  name                = "wandb-appgateway"
  resource_group_name = azurerm_resource_group.wandb.name
  location            = azurerm_resource_group.wandb.location

  sku {
    name     = var.use_web_application_firewall ? "WAF_v2" : "Standard_v2"
    tier     = var.use_web_application_firewall ? "WAF_v2" : "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.frontend.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_port {
    name = "https_port"
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.wandb.id
  }

  frontend_ip_configuration {
    name                          = "${local.frontend_ip_configuration_name}-private"
    subnet_id                     = azurerm_subnet.frontend.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.private_ip
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

  firewall_policy_id = var.use_web_application_firewall ? azurerm_web_application_firewall_policy.wandb.id : null

  depends_on = [
    azurerm_virtual_network.wandb,
    azurerm_public_ip.wandb,
  ]

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

data "azurerm_application_gateway" "wandb" {
  name                = "wandb-appgateway"
  resource_group_name = azurerm_resource_group.wandb.name

  depends_on = [
    azurerm_application_gateway.wandb
  ]
}
