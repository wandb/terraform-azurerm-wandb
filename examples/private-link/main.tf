terraform {
  required_version = "~> 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.17"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

provider "azapi" {
  subscription_id = var.subscription_id
}

# Create Virtual Network if create_network is true
resource "azurerm_virtual_network" "new_vnet" {
  count               = var.create_network ? 1 : 0
  name                = var.new_vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.new_vnet_address_space
}

# Create Subnet if create_network is true
resource "azurerm_subnet" "new_subnet" {
  count                = var.create_network ? 1 : 0
  name                 = var.new_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.new_vnet[0].name
  address_prefixes     = var.new_subnet_address_prefixes
}

# Reference existing Subnet if create_network is false
data "azurerm_subnet" "private_subnet" {
  count                = var.create_network ? 0 : 1
  name                 = var.existing_subnet_name
  virtual_network_name = var.existing_vnet_name
  resource_group_name  = var.resource_group_name
}

# Reference existing Virtual Network if create_network is false
data "azurerm_virtual_network" "vnet" {
  count               = var.create_network ? 0 : 1
  name                = var.existing_vnet_name
  resource_group_name = var.resource_group_name
}

# Select appropriate subnet and virtual network ID
locals {
  subnet_id          = var.create_network ? azurerm_subnet.new_subnet[0].id : (length(data.azurerm_subnet.private_subnet) > 0 ? data.azurerm_subnet.private_subnet[0].id : "")
  virtual_network_id = var.create_network ? azurerm_virtual_network.new_vnet[0].id : (length(data.azurerm_virtual_network.vnet) > 0 ? data.azurerm_virtual_network.vnet[0].id : "")
}

resource "azurerm_private_endpoint" "private_endpoint" {
  name                = var.private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = local.subnet_id

  private_service_connection {
    name                           = "app-gateway-private-connection"
    private_connection_resource_id = var.private_link_resource_id
    is_manual_connection           = true
    subresource_names              = [var.private_link_sub_resource_name]
    request_message                = "Requesting Private Link connection for Application Gateway"
  }

  lifecycle {
    prevent_destroy = false
  }
}

# Create Private DNS Zone if requested
resource "azurerm_private_dns_zone" "private_dns" {
  count               = var.create_private_dns_zone ? 1 : 0
  name                = var.private_dns_zone_name
  resource_group_name = var.resource_group_name
}

# Reference existing Private DNS Zone if provided
data "azurerm_private_dns_zone" "existing_private_dns" {
  count               = var.create_private_dns_zone ? 0 : 1
  name                = var.existing_private_dns_zone_name
  resource_group_name = var.resource_group_name
}

# Determine which Private DNS Zone ID to use
locals {
  private_dns_zone_id = var.create_private_dns_zone ? azurerm_private_dns_zone.private_dns[0].id : (length(data.azurerm_private_dns_zone.existing_private_dns) > 0 ? data.azurerm_private_dns_zone.existing_private_dns[0].id : "")
}

# Create A Record for Private Endpoint
resource "azurerm_private_dns_a_record" "app_gateway_a_record" {
  name                = var.dns_name_a_record
  zone_name           = coalesce(var.existing_private_dns_zone_name, var.private_dns_zone_name)
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.private_endpoint.private_service_connection[0].private_ip_address]

  depends_on = [azurerm_private_dns_zone.private_dns]
}

# Reference existing DNS Virtual Network Link
data "azurerm_private_dns_zone_virtual_network_link" "existing_dns_link" {
  count                 = var.create_private_dns_zone ? 0 : 1
  name                  = var.dns_link_name
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = coalesce(var.existing_private_dns_zone_name, var.private_dns_zone_name)
}

# Manage Private DNS Virtual Network Link
resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
  count                 = length(data.azurerm_private_dns_zone_virtual_network_link.existing_dns_link) == 0 ? 1 : 0
  name                  = var.dns_link_name
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = coalesce(var.existing_private_dns_zone_name, var.private_dns_zone_name)
  virtual_network_id    = local.virtual_network_id

  depends_on = [azurerm_private_dns_zone.private_dns]
}