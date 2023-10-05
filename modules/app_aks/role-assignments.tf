locals {
  ingress_gateway_principal_id = azurerm_kubernetes_cluster.default.ingress_application_gateway.0.ingress_application_gateway_identity.0.object_id
}

resource "azurerm_role_assignment" "gateway" {
  scope                = var.gateway.id
  role_definition_name = "Contributor"
  principal_id         = local.ingress_gateway_principal_id
}

resource "azurerm_role_assignment" "public_subnet" {
  scope                = var.public_subnet.id
  role_definition_name = "Contributor"
  principal_id         = local.ingress_gateway_principal_id
}

resource "azurerm_role_assignment" "resource_group" {
  scope                = var.resource_group.id
  role_definition_name = "Reader"
  principal_id         = local.ingress_gateway_principal_id
}


