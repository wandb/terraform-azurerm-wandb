output "azuread_application_id" {
  value = azuread_application.example.id
}

output "azuread_service_principal_id" {
  value = azuread_service_principal.example.id
}

output "azuread_service_principal_display_name" {
  value = azuread_service_principal.example.display_name
}

#output "azuread_application_name" {
#  value = azuread_application.example.
#}