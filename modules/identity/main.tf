resource "azurerm_user_assigned_identity" "default" {
  name                = "${var.namespace}-identity"
  location            = var.location
  resource_group_name = var.resource_group.name
}
