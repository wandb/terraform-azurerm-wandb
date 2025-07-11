output "private_ip_address" {
  description = "Private IP address of the Private Endpoint"
  value       = azurerm_private_endpoint.private_endpoint.private_service_connection[0].private_ip_address
}

output "private_url" {
  description = "Full Private URL"
  value       = "${azurerm_private_dns_a_record.app_gateway_a_record.name}.${coalesce(var.existing_private_dns_zone_name, var.private_dns_zone_name)}"
}