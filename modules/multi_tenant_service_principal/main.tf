data "azuread_client_config" "current" {}

resource "azuread_application" "example" {
  #  resource_group_name = var.resource_group_name

  display_name     = "${var.namespace} Application"
  owners           = [data.azuread_client_config.current.object_id]
  sign_in_audience = "AzureADMultipleOrgs"
}

resource "azuread_service_principal" "example" {
  #  resource_group_name = var.resource_group_name

  client_id                    = azuread_application.example.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}