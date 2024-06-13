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

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.17 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.6 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.23 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.17 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_app_aks"></a> [app\_aks](#module\_app\_aks) | ./modules/app_aks | n/a |
| <a name="module_app_lb"></a> [app\_lb](#module\_app\_lb) | ./modules/app_lb | n/a |
| <a name="module_cert_manager"></a> [cert\_manager](#module\_cert\_manager) | ./modules/cert_manager | n/a |
| <a name="module_cron_job"></a> [cron\_job](#module\_cron\_job) | ./modules/cron_job | n/a |
| <a name="module_database"></a> [database](#module\_database) | ./modules/database | n/a |
| <a name="module_identity"></a> [identity](#module\_identity) | ./modules/identity | n/a |
| <a name="module_networking"></a> [networking](#module\_networking) | ./modules/networking | n/a |
| <a name="module_pod_identity"></a> [pod\_identity](#module\_pod\_identity) | ./modules/identity | n/a |
| <a name="module_redis"></a> [redis](#module\_redis) | ./modules/redis | n/a |
| <a name="module_storage"></a> [storage](#module\_storage) | ./modules/storage | n/a |
| <a name="module_vault"></a> [vault](#module\_vault) | ./modules/vault | n/a |
| <a name="module_wandb"></a> [wandb](#module\_wandb) | wandb/wandb/helm | 1.2.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|

| <a name="input_allowed_subscriptions"></a> [allowed\_subscriptions](#input\_allowed\_subscriptions) | List of allowed customer subscriptions coma seperated values | `string` | `""` | no |
| <a name="input_allowed_ip_ranges"></a> [allowed\_ip\_ranges](#input\_allowed\_ip\_ranges) | allowed public IP addresses or CIDR ranges. | `list(string)` | `[]` | no |
| <a name="input_app_wandb_env"></a> [app\_wandb\_env](#input\_app\_wandb\_env) | Extra environment variables for W&B | `map(string)` | `{}` | no |
| <a name="input_azuremonitor"></a> [azuremonitor](#input\_azuremonitor) | # To support otel azure monitor sql and redis metrics need operator-wandb chart minimum version 0.14.0 | `bool` | `true` | no |
| <a name="input_blob_container"></a> [blob\_container](#input\_blob\_container) | Use an existing bucket. | `string` | `""` | no |
| <a name="input_create_private_link"></a> [create\_private\_link](#input\_create\_private\_link) | Use for the azure private link. | `bool` | `false` | no |

| <a name="input_cluster_sku_tier"></a> [cluster\_sku\_tier](#input\_cluster\_sku\_tier) | The Azure AKS SKU Tier to use for this cluster (https://learn.microsoft.com/en-us/azure/aks/free-standard-pricing-tiers) | `string` | `"Free"` | no |

| <a name="input_create_redis"></a> [create\_redis](#input\_create\_redis) | Boolean indicating whether to provision an redis instance (true) or not (false). | `bool` | `false` | no |
| <a name="input_database_availability_mode"></a> [database\_availability\_mode](#input\_database\_availability\_mode) | n/a | `string` | `"SameZone"` | no |
| <a name="input_database_sku_name"></a> [database\_sku\_name](#input\_database\_sku\_name) | Specifies the SKU Name for this MySQL Server | `string` | `"GP_Standard_D4ds_v4"` | no |
| <a name="input_database_version"></a> [database\_version](#input\_database\_version) | Version for MySQL | `string` | `"5.7"` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | If the instance should have deletion protection enabled. The database / Bucket can't be deleted when this value is set to `true`. | `bool` | `true` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Domain for accessing the Weights & Biases UI. | `string` | `null` | no |
| <a name="input_external_bucket"></a> [external\_bucket](#input\_external\_bucket) | config an external bucket | `any` | `null` | no |
| <a name="input_kubernetes_instance_type"></a> [kubernetes\_instance\_type](#input\_kubernetes\_instance\_type) | Use for the Kubernetes cluster. | `string` | `"Standard_D4a_v4"` | no |
| <a name="input_kubernetes_node_count"></a> [kubernetes\_node\_count](#input\_kubernetes\_node\_count) | n/a | `number` | `2` | no |
| <a name="input_license"></a> [license](#input\_license) | Your wandb/local license | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | String used for prefix resources. | `string` | n/a | yes |
| <a name="input_node_max_pods"></a> [node\_max\_pods](#input\_node\_max\_pods) | Maximum number of pods per node | `number` | `30` | no |
| <a name="input_oidc_auth_method"></a> [oidc\_auth\_method](#input\_oidc\_auth\_method) | OIDC auth method | `string` | `"implicit"` | no |
| <a name="input_oidc_client_id"></a> [oidc\_client\_id](#input\_oidc\_client\_id) | The Client ID of application in your identity provider | `string` | `""` | no |
| <a name="input_oidc_issuer"></a> [oidc\_issuer](#input\_oidc\_issuer) | A url to your Open ID Connect identity provider, i.e. https://cognito-idp.us-east-1.amazonaws.com/us-east-1_uiIFNdacd | `string` | `""` | no |
| <a name="input_oidc_secret"></a> [oidc\_secret](#input\_oidc\_secret) | The Client secret of application in your identity provider | `string` | `""` | no |
| <a name="input_other_wandb_env"></a> [other\_wandb\_env](#input\_other\_wandb\_env) | Extra environment variables for W&B | `map(any)` | `{}` | no |
| <a name="input_parquet_wandb_env"></a> [parquet\_wandb\_env](#input\_parquet\_wandb\_env) | Extra environment variables for W&B | `map(string)` | `{}` | no |
| <a name="input_ssl"></a> [ssl](#input\_ssl) | Enable SSL certificate | `bool` | `true` | no |
| <a name="input_storage_account"></a> [storage\_account](#input\_storage\_account) | Azure storage account name | `string` | `""` | no |
| <a name="input_storage_key"></a> [storage\_key](#input\_storage\_key) | Azure primary storage access key | `string` | `""` | no |
| <a name="input_subdomain"></a> [subdomain](#input\_subdomain) | Subdomain for accessing the Weights & Biases UI. Default creates record at Route53 Route. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags for resource | `map(string)` | `{}` | no |
| <a name="input_use_internal_queue"></a> [use\_internal\_queue](#input\_use\_internal\_queue) | Uses an internal redis queue instead of using azure queue. | `bool` | `false` | no |
| <a name="input_wandb_image"></a> [wandb\_image](#input\_wandb\_image) | Docker repository of to pull the wandb image from. | `string` | `"wandb/local"` | no |
| <a name="input_wandb_version"></a> [wandb\_version](#input\_wandb\_version) | The version of Weights & Biases local to deploy. | `string` | `"latest"` | no |
| <a name="input_weave_wandb_env"></a> [weave\_wandb\_env](#input\_weave\_wandb\_env) | Extra environment variables for W&B | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address"></a> [address](#output\_address) | n/a |
| <a name="output_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#output\_cluster\_ca\_certificate) | n/a |
| <a name="output_cluster_client_certificate"></a> [cluster\_client\_certificate](#output\_cluster\_client\_certificate) | n/a |
| <a name="output_cluster_client_key"></a> [cluster\_client\_key](#output\_cluster\_client\_key) | n/a |
| <a name="output_cluster_host"></a> [cluster\_host](#output\_cluster\_host) | n/a |
| <a name="output_fqdn"></a> [fqdn](#output\_fqdn) | The FQDN to the W&B application |
| <a name="output_private_link_resource_id"></a> [private\_link\_resource\_id](#output\_private\_link\_resource\_id) | n/a |
| <a name="output_private_link_sub_resource_name"></a> [private\_link\_sub\_resource\_name](#output\_private\_link\_sub\_resource\_name) | n/a |
| <a name="output_oidc_issuer_url"></a> [oidc\_issuer\_url](#output\_oidc\_issuer\_url) | n/a |
| <a name="output_storage_account"></a> [storage\_account](#output\_storage\_account) | n/a |
| <a name="output_storage_container"></a> [storage\_container](#output\_storage\_container) | n/a |
| <a name="output_url"></a> [url](#output\_url) | The URL to the W&B application |
<!-- END_TF_DOCS -->
