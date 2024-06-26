# Weights & Biases Secure Storage Connector Module

This is a Terraform module for provisioning an azure storage container to be used with Weights and Biases.
A managed identity (with a federated credential) used to auth to the container will also be created. To use this container with Weights and Biases
dedicated azure deployment, pass the OIDC issuer URL from the AKS cluster that will connect to this container for the `oidc_issuer_url` variable. 

## Azure Services Used

- Microsoft Entra ID (formerly Azure Active Directory)
- Azure Blob Storage

## How to Use This Module

- Create a Terraform configuration that pulls in this module and specifies
  values of the required variables:

```
provider "azurerm" {
  features {} 
  subscription_id = "<your subscription id>"
  tenant_id       = "<your tenant id>"
}

module "secure_storage_connector" {
  source              = "wandb/wandb/azure/modules/secure_storage_connector"
  namespace           = "<prefix for naming Azure resources>"
  resource_group_name = "<name of already existing resource group in which to create the managed identity and storage account.>"
  oidc_issuer_url     = "<OIDC issuer URL from the AKS cluster that is meant to connect to this container. Make sure to include the trailing '/'>"
}
```

- Run `terraform init`
- Run `terraform apply` to build the actual storage account and container.
  - Important: Make sure to include the trailing '/' from the OIDC provider URL when specifying the `oidc_issuer_url` variable.
Here is an example `https://centralus.oic.prod-aks.azure.com/be722674-83b6-4adc-9c58-c793986eab4a/0cf6e291-489e-4c39-a683-93a6f7ba5a84/`
- To use the provisioned container at the team-level, use the output values from this module's terraform when configuring the bucket in the Weights & Biases Create Team UI panel. 

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version |
|--------------------------------------------------------------------------| ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.17 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.17 |

## Inputs

| Name                                                                                       | Description                                                                                                                      | Type     | Default | Required |
|--------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------|----------|---------|:--------:|
| <a name="input_namespace"></a> [namespace](#input_namespace)                               | Prefix to use when creating resources.                                                                                           | `string` | n/a     |   yes    |
| <a name="input_oidc_issuer_url"></a> [oidc_issuer_url](#input_oidc_issuer_url)             | OIDC issuer URL from the AKS cluster that is meant to connect to this container. Make sure to include the trailing '/'           | `string` | n/a     |   yes    |
| <a name="input_deletion_protection"></a> [deletion_protection](#input_deletion_protection) | If the instance should have deletion protection enabled. The storage container can't be deleted when this value is set to `true` | `bool`   | true    |    no    |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name) | The name of the resource group in which to create the managed identity and storage account.                                      | `string` | n/a     |   yes    |

## Outputs

| Name                                                                                                | Description                                                          |
|-----------------------------------------------------------------------------------------------------|----------------------------------------------------------------------|
| <a name="storage_account_name"></a> [storage_account_name](#storage_account_name)                   | The name of the storage account created                              |
| <a name="storage_container_name"></a> [storage_container_name](#storage_container_name)             | The name of the storage container created                            |
| <a name="managed_identity_client_id"></a> [managed_identity_client_id](#managed_identity_client_id) | The Client ID of the Managed Identity created                        |
| <a name="tenant_id"></a> [tenant_id](#tenant_id)                                                    | The Tenant ID of the Azure Directory where the resources are created |

<!-- END_TF_DOCS -->