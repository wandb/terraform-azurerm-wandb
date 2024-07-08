output "address" {
  value = azurerm_public_ip.default.ip_address
}

output "gateway" {
  value = azurerm_application_gateway.default
}

output "gateway_id" {
  value = azurerm_application_gateway.default.id
}

output "frontend_ip_configuration_names" {
  value = azurerm_application_gateway.default.frontend_ip_configuration[1].name
}