# Weights & Biases Azure Module

This is a Terraform module for provisioning a Weights & Biases Cluster on Azure.
Weights & Biases Server is our self-hosted distribution of wandb.ai. It offers
enterprises a private instance of the Weights & Biases application, with no
resource limits and with additional enterprise-grade architectural features like
audit logging and single sign-on.

## About This Module

## Pre-requisites

This module is intended to run in an Azure account with minimal
preparation, however it does have the following pre-requisites:

### Terraform version >= 1

### Credentials / Permissions

## How to Use This Module

## Examples

We have included documentation and reference examples for additional common
installation scenarios for Weights & Biases, as well as examples for supporting
resources that lack official modules.

- Route

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                        | Version |
| --------------------------------------------------------------------------- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform)    | ~> 1.0  |
| <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm)          | ~> 3.17 |
| <a name="requirement_helm"></a> [helm](#requirement_helm)                   | ~> 2.6  |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement_kubernetes) | ~> 2.12 |

## Providers

| Name                                                         | Version |
| ------------------------------------------------------------ | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider_azurerm) | ~> 3.17 |

## Modules

| Name                                                                    | Source                 | Version |
| ----------------------------------------------------------------------- | ---------------------- | ------- |
| <a name="module_app_aks"></a> [app_aks](#module_app_aks)                | ./modules/app_aks      | n/a     |
| <a name="module_app_lb"></a> [app_lb](#module_app_lb)                   | ./modules/app_lb       | n/a     |
| <a name="module_cert_manager"></a> [cert_manager](#module_cert_manager) | ./modules/cert_manager | n/a     |
| <a name="module_database"></a> [database](#module_database)             | ./modules/database     | n/a     |
| <a name="module_networking"></a> [networking](#module_networking)       | ./modules/networking   | n/a     |
| <a name="module_storage"></a> [storage](#module_storage)                | ./modules/storage      | n/a     |

## Resources

| Name | Type |
| ---- | ---- |

## Inputs

| Name                                                                                       | Description                                                                                                                       | Type          | Default         | Required |
| ------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------- | ------------- | --------------- | :------: |
| <a name="input_blob_container"></a> [blob_container](#input_blob_container)                | Use an existing bucket.                                                                                                           | `string`      | `""`            |    no    |
| <a name="input_create_redis"></a> [create_redis](#input_create_redis)                      | Boolean indicating whether to provision an redis instance (true) or not (false).                                                  | `bool`        | `false`         |    no    |
| <a name="input_database_version"></a> [database_version](#input_database_version)          | Version for MySQL                                                                                                                 | `string`      | `"8.0.21"`      |    no    |
| <a name="input_deletion_protection"></a> [deletion_protection](#input_deletion_protection) | If the instance should have deletion protection enabled. The database / Bucket can't be deleted when this value is set to `true`. | `bool`        | `true`          |    no    |
| <a name="input_domain_name"></a> [domain_name](#input_domain_name)                         | Domain for accessing the Weights & Biases UI.                                                                                     | `string`      | `null`          |    no    |
| <a name="input_license"></a> [license](#input_license)                                     | Your wandb/local license                                                                                                          | `string`      | n/a             |   yes    |
| <a name="input_location"></a> [location](#input_location)                                  | n/a                                                                                                                               | `string`      | n/a             |   yes    |
| <a name="input_namespace"></a> [namespace](#input_namespace)                               | String used for prefix resources.                                                                                                 | `string`      | n/a             |   yes    |
| <a name="input_oidc_auth_method"></a> [oidc_auth_method](#input_oidc_auth_method)          | OIDC auth method                                                                                                                  | `string`      | `"implicit"`    |    no    |
| <a name="input_oidc_client_id"></a> [oidc_client_id](#input_oidc_client_id)                | The Client ID of application in your identity provider                                                                            | `string`      | `""`            |    no    |
| <a name="input_oidc_issuer"></a> [oidc_issuer](#input_oidc_issuer)                         | A url to your Open ID Connect identity provider, i.e. https://cognito-idp.us-east-1.amazonaws.com/us-east-1_uiIFNdacd             | `string`      | `""`            |    no    |
| <a name="input_ssl"></a> [ssl](#input_ssl)                                                 | Enable SSL certificate                                                                                                            | `bool`        | `true`          |    no    |
| <a name="input_subdomain"></a> [subdomain](#input_subdomain)                               | Subdomain for accessing the Weights & Biases UI. Default creates record at Route53 Route.                                         | `string`      | `null`          |    no    |
| <a name="input_tags"></a> [tags](#input_tags)                                              | Map of tags for resource                                                                                                          | `map(string)` | `{}`            |    no    |
| <a name="input_use_internal_queue"></a> [use_internal_queue](#input_use_internal_queue)    | Uses an internal redis queue instead of using azure pubsub.                                                                       | `bool`        | `false`         |    no    |
| <a name="input_wandb_image"></a> [wandb_image](#input_wandb_image)                         | Docker repository of to pull the wandb image from.                                                                                | `string`      | `"wandb/local"` |    no    |
| <a name="input_wandb_version"></a> [wandb_version](#input_wandb_version)                   | The version of Weights & Biases local to deploy.                                                                                  | `string`      | `"latest"`      |    no    |

## Outputs

| Name                                                                                                              | Description |
| ----------------------------------------------------------------------------------------------------------------- | ----------- |
| <a name="output_cluster_ca_certificate"></a> [cluster_ca_certificate](#output_cluster_ca_certificate)             | n/a         |
| <a name="output_cluster_client_certificate"></a> [cluster_client_certificate](#output_cluster_client_certificate) | n/a         |
| <a name="output_cluster_client_key"></a> [cluster_client_key](#output_cluster_client_key)                         | n/a         |
| <a name="output_cluster_host"></a> [cluster_host](#output_cluster_host)                                           | n/a         |

<!-- END_TF_DOCS -->
