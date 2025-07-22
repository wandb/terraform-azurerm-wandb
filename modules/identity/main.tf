resource "azurerm_user_assigned_identity" "default" {
  name                = "${var.namespace}-identity"
  location            = var.location
  resource_group_name = var.resource_group.name
}

resource "azurerm_user_assigned_identity" "otel" {
  count               = var.otel_identity ? 1 : 0
  name                = "${var.namespace}-identity-otel"
  location            = var.location
  resource_group_name = var.resource_group.name
}
