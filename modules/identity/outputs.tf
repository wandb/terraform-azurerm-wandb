output "identity" {
  value = azurerm_user_assigned_identity.default
}
output "otel_identity" {
  value = var.otel_identity ? azurerm_user_assigned_identity.otel[0] : null
}