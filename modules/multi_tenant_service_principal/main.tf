data "azuread_client_config" "current" {}

resource "azuread_application" "example" {
  display_name     = "${var.namespace} Application"
  owners           = [data.azuread_client_config.current.object_id]
  sign_in_audience = "AzureADMultipleOrgs"

  feature_tags {
    enterprise = true
  }
}

resource "azuread_service_principal" "example" {
  client_id                    = azuread_application.example.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}

#resource "azuread_application_registration" "example" {
#  display_name = "example"
#}

#resource "time_rotating" "rotate" {
#  rotation_days = 7
#}

#resource "azuread_application_password" "secret" {
#  application_id = azuread_application.example.id
#  rotate_when_changed = {
#    rotation = time_rotating.rotate.id
#  }
#}