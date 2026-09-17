mock_provider "azurerm" {
  mock_data "azurerm_client_config" {
    defaults = {
      tenant_id = "00000000-0000-0000-0000-000000000001"
      object_id = "00000000-0000-0000-0000-000000000002"
    }
  }
}

mock_provider "kubernetes" {}
mock_provider "random" {}

variables {
  identity_object_id = "00000000-0000-0000-0000-000000000003"
  location           = "westeurope"
  namespace          = "inventory-test"
  resource_group = {
    name = "inventory-test"
    id   = "/subscriptions/00000000-0000-0000-0000-000000000005/resourceGroups/inventory-test"
  }
  tags = {}
}

run "default_adds_no_inventory_access" {
  command = plan
  module { source = "./modules/vault" }

  assert {
    condition     = length(azurerm_key_vault_access_policy.additional_list_only) == 0
    error_message = "Existing installations must not gain inventory access by default."
  }
}

run "explicit_principal_gets_only_metadata_list" {
  command = plan
  module { source = "./modules/vault" }

  variables {
    additional_list_only_principal_ids = [
      "abcdefab-0000-0000-0000-000000000004",
      "ABCDEFAB-0000-0000-0000-000000000004",
    ]
  }

  assert {
    condition     = length(azurerm_key_vault_access_policy.additional_list_only) == 1
    error_message = "UUID casing must not create duplicate policies for a principal."
  }

  assert {
    condition = alltrue([
      for policy in azurerm_key_vault_access_policy.additional_list_only :
      policy.object_id == "abcdefab-0000-0000-0000-000000000004" &&
      policy.tenant_id == "00000000-0000-0000-0000-000000000001" &&
      toset(policy.key_permissions) == toset(["List"]) &&
      toset(policy.secret_permissions) == toset(["List"]) &&
      toset(policy.certificate_permissions) == toset(["List"]) &&
      length(coalesce(policy.storage_permissions, [])) == 0
    ])
    error_message = "Inventory policies must grant only List for keys, secrets, and certificates in the current tenant."
  }
}

run "reject_invalid_principal" {
  command = plan
  module { source = "./modules/vault" }
  variables { additional_list_only_principal_ids = ["not-an-object-id"] }
  expect_failures = [var.additional_list_only_principal_ids]
}

run "reject_null_principal" {
  command = plan
  module { source = "./modules/vault" }
  variables { additional_list_only_principal_ids = [null] }
  expect_failures = [var.additional_list_only_principal_ids]
}

run "preserve_deployer_permissions" {
  command = plan
  module { source = "./modules/vault" }
  variables { additional_list_only_principal_ids = ["00000000-0000-0000-0000-000000000002"] }
  expect_failures = [azurerm_key_vault_access_policy.additional_list_only]
}

run "preserve_workload_identity_permissions" {
  command = plan
  module { source = "./modules/vault" }
  variables { additional_list_only_principal_ids = ["00000000-0000-0000-0000-000000000003"] }
  expect_failures = [azurerm_key_vault_access_policy.additional_list_only]
}
