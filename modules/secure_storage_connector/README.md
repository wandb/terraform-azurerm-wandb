# Weights & Biases Secure Storage Connector Module

This is a Terraform module for provisioning a team-level azure storage container to be used with Weights and Biases.
A resource group and managed identity used to auth to the container will also be created by default. To use this bucket with Weights and Biases
dedicated azure deployment, you will also need to run a command to create a federated credential. 

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
  source    = "wandb/wandb/azure/modules/secure_storage_connector"
  namespace = "<prefix for naming Azure resources>"
  location  = "<Azure Region where resources will be created>"
}
```

- Run `terraform init` and `terraform apply`
- Request the OIDC provider URL from the wandb team, so you can use it in the following command.
- Create the federated credential by running the following command:
```
az identity federated-credential create \
  --name cross-tenant-federated-cred \
  --identity-name <Name of managed identity)> \
  --resource-group <Name of resource group> \
  --issuer <OIDC provider URL> \
  --subject system:serviceaccount:default:wandb-app
```
Note: the arguments for `--identity-name` and `--resource-group` are from this terraform module's outputs (`managed_identity_name` and `resource_group_name` respectively)
while the `--issuer` value comes from the output of the terraform used to provision the dedicated instance.

Important: Make sure to include the trailing '/' from the OIDC provider URL. Here is an example `https://centralus.oic.prod-aks.azure.com/af722783-84b6-4adc-9c49-c792786eab4a/0ff6e291-489e-4c39-a683-93a6f7ba5a84/`

- To use the provisioned container at the team-level, include the tenantID where this container was created and the  output values (from this module's terraform) when configuring the bucket in the Weights & Biases Create Team UI panel. 

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

| Name                                                         | Description                                                                                                                                    | Type     | Default | Required |
|--------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------|----------|---------|:--------:|
| <a name="input_namespace"></a> [namespace](#input_namespace) | Prefix to use when creating resources.                                                                                                         | `string` | n/a     |   yes    |
| <a name="input_location"></a> [location](#input_location)   | The Azure Region where resources will be created. | `string` | n/a     |   yes    |


## Outputs

| Name                                                                        | Description                                   |
|-----------------------------------------------------------------------------|-----------------------------------------------|
| <a name="resource_group_name"></a> [resource_group_name](#resource_group_name)                      | The name of the Resource Group created        |
| <a name="managed_identity_name"></a> [managed_identity_name](#managed_identity_name)                  | The name of the Managed Identity created      |
| <a name="managed_identity_client_id"></a> [managed_identity_client_id](#managed_identity_client_id) | The Client ID of the Managed Identity created |
| <a name="storage_account_name"></a> [storage_account_name](#storage_account_name) | The name of the storage account created       |
| <a name="storage_container_name"></a> [storage_container_name](#storage_container_name) | The name of the storage container created     |

<!-- END_TF_DOCS -->