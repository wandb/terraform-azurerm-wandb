output "address" {
  value = azurerm_public_ip.default.ip_address
}

output "gateway" {
  value = azurerm_application_gateway.default
}
