resource "azurerm_user_assigned_identity" "clickhouse" {
  name                = "${var.namespace}-clickhouse-identity"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_federated_identity_credential" "clickhouse" {
  parent_id           = azurerm_user_assigned_identity.clickhouse.id
  name                = "${var.namespace}-clickhouse-credentials"
  resource_group_name = var.resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.oidc_issuer_url
  subject             = "system:serviceaccount:${var.k8s_namespace}:${var.k8s_service_account_name}"
}

resource "azurerm_role_assignment" "storage_account_contributor" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Account Contributor"
  principal_id         = azurerm_user_assigned_identity.clickhouse.principal_id
}

resource "azurerm_role_assignment" "storage_blob_data_owner" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azurerm_user_assigned_identity.clickhouse.principal_id
}
