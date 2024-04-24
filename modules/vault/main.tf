
data "azurerm_client_config" "current" {}

locals {
  vault_name           = "${var.namespace}-vault"
  vault_truncated_name = substr(local.vault_name, 0, min(length(local.vault_name), 24))
}

resource "azurerm_key_vault" "default" {
  name                = trim(local.vault_truncated_name, "-")
  location            = var.location
  resource_group_name = var.resource_group.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  enabled_for_disk_encryption = true

  sku_name = "standard"

  network_acls {
    bypass         = "AzureServices"
    default_action = "Allow"
  }

  tags = var.tags
}

resource "azurerm_key_vault_certificate" "example" {
  name         = "generated-cert"
  key_vault_id = azurerm_key_vault.default.id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      extended_key_usage = ["1.3.6.1.5.5.7.3.2"]

      key_usage = [
        "dataEncipherment",
        "digitalSignature",
        "keyCertSign",
        "keyEncipherment",
      ]

#      don't know what the alternatives would be?
#      subject_alternative_names {
#        dns_names = ["${var.resource_group.name}.wandb.ml"]
#      }

#      subject            = "CN=${azuread_application.example.name}"
      subject            = "CN=${var.azuread_service_principal_display_name}"
      validity_in_months = 12
    }
  }
}

resource "azuread_service_principal_certificate" "example" {
#  application_id = var.azuread_service_principal_id
  type           = "AsymmetricX509Cert"
  encoding       = "hex"
  value          = azurerm_key_vault_certificate.example.certificate_data
  end_date       = azurerm_key_vault_certificate.example.certificate_attribute[0].expires
  start_date     = azurerm_key_vault_certificate.example.certificate_attribute[0].not_before
  service_principal_id = var.azuread_service_principal_id
}

resource "azuread_application_certificate" "example" {
  application_id = var.azuread_application_id
  type           = "AsymmetricX509Cert"
  encoding       = "hex"
  value          = azurerm_key_vault_certificate.example.certificate_data
  end_date       = azurerm_key_vault_certificate.example.certificate_attribute[0].expires
  start_date     = azurerm_key_vault_certificate.example.certificate_attribute[0].not_before
}

resource "azurerm_key_vault_access_policy" "parent" {
  key_vault_id = azurerm_key_vault.default.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions     = ["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "GetRotationPolicy", "List", "Purge", "Recover", "Restore", "Rotate"]
  secret_permissions  = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
  storage_permissions = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore"]
  certificate_permissions = [      "Get",
    "List",
    "Update",
    "Create",
    "Import",
    "Delete",
    "Recover",
    "Backup",
    "Restore",
    "Purge",]

  depends_on = [azurerm_key_vault.default]
}

resource "azurerm_key_vault_access_policy" "identity" {
  key_vault_id = azurerm_key_vault.default.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.identity_object_id

  key_permissions     = ["Create", "Decrypt", "Encrypt", "Get", "List"]
  secret_permissions  = ["Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
  storage_permissions = ["Get", "List"]
  certificate_permissions = [      "Get",
    "List",
    "Update",
    "Create",
    "Import",
    "Delete",
    "Recover",
    "Backup",
    "Restore",
    "Purge",]

  depends_on = [azurerm_key_vault.default]
}

resource "azurerm_key_vault_key" "etcd" {
  depends_on = [azurerm_key_vault_access_policy.parent, azurerm_key_vault_access_policy.identity]

  name         = "generated-etcd-key"
  key_vault_id = azurerm_key_vault.default.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey", ]
}