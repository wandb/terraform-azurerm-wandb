# Weights & Biases Azure Module

This is a Terraform module for provisioning a Weights & Biases Cluster on Azure.
Weights & Biases Server is our self-hosted distribution of wandb.ai. It offers
enterprises a private instance of the Weights & Biases application, with no
resource limits and with additional enterprise-grade architectural features like
audit logging and single sign-on.

## About This Module

This module provisions the Azure infrastructure and Kubernetes integrations
required for a W&B Server deployment. The default architecture includes:

- An Azure Virtual Network and dedicated AKS, MySQL, Redis, and ingress subnets.
- Azure Kubernetes Service with OIDC and Azure Workload Identity enabled.
- Azure Application Gateway with the AKS Application Gateway Ingress Controller.
- Azure Database for MySQL Flexible Server on a delegated private subnet.
- Azure Managed Redis with TLS and a private endpoint by default.
- Azure Storage, Key Vault, managed identities, and optional customer-managed keys.
- cert-manager, a Let's Encrypt ClusterIssuer, and the W&B operator/CR charts.

The request path for a public deployment is:

```text
Client -> Azure Application Gateway -> Kubernetes Ingress -> W&B services
```

The deployment uses the Kubernetes Ingress API with the
`azure/application-gateway` ingress class. It does not use Kubernetes Gateway
API resources such as `Gateway` or `HTTPRoute`.

## Pre-requisites

This module is intended to run in an Azure account with minimal
preparation, however it does have the following pre-requisites:

- Terraform `~> 1.9`.
- Azure CLI authentication for the target subscription.
- Permissions to create Azure resources, role assignments, federated identity
  credentials, and resource locks when deletion protection is enabled.
- Control of the public DNS zone used by the W&B hostname.
- A W&B Server license.

The module does not create the public DNS record. After Application Gateway is
created, point the W&B hostname at the `address` output. Public HTTPS issuance
uses an ACME HTTP-01 challenge, so the hostname must resolve to Application
Gateway and accept public traffic on port 80.

## How to Use This Module

The module supports two deployment workflows. Choose one owner for the W&B
operator and custom resource; do not manage the same release both through
Terraform and a manual `kubectl apply`.

### Terraform-managed application

The default values of `enable_helm_operator = true` and
`enable_helm_wandb = true` install the operator and W&B custom resource after
the infrastructure is available.

```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

Terraform plan files and state can contain credentials. Store state in a secure
remote backend and do not commit saved plans or `.tfvars` files.

### Staged infrastructure and manual CR

For a staged rollout, set both Helm switches to `false`, apply the
infrastructure, configure DNS, and install the W&B operator separately. Copy
[`CR.template.yaml`](CR.template.yaml) to an environment-specific `CR.yaml`,
replace every `REPLACE_ME_*` value, and create the three secrets documented at
the top of the template:

- `wandb-license`, with key `license`.
- `wandb-mysql`, with key `password`.
- `wandb-redis`, with key `password`.

The rendered CR contains a live Azure Storage access key because the current
application image set cannot yet be assumed to use Workload Identity for every
storage operation. The repository ignores environment-specific `*CR.yaml`
files; never commit a rendered CR.

Validate the CR against the installed operator before applying it:

```bash
kubectl apply --dry-run=server -f CR.yaml
kubectl apply -f CR.yaml
kubectl get weightsandbiases,pods,ingress,certificate -n <namespace>
```

## Cluster Sizing

By default, the type of kubernetes instances, number of instances, redis cluster size, and database instance sizes are
standardized via configurations in [./deployment-size.tf](deployment-size.tf), and is configured via the `size` input
variable.

Available sizes are, `small`, `medium`, `large`, `xlarge`, and `xxlarge`.  Default is `small`.

All the values set via `deployment-size.tf` can be overridden by setting the appropriate input variables.

- `kubernetes_instance_type` - The VM size for the AKS nodes
- `kubernetes_min_node_per_az` - The minimum number of AKS nodes per zone
- `kubernetes_max_node_per_az` - The maximum number of AKS nodes per zone
- `redis_sku_name` - The Azure Managed Redis SKU
- `database_sku_name` - The Azure Database for MySQL SKU

Azure Managed Redis capacity is region-dependent. If Azure reports insufficient
capacity, select another supported `redis_sku_name` or deploy to another region.

## Azure Managed Redis

The module uses Azure Managed Redis rather than the retiring Azure Cache for
Redis resource. The managed database is configured with:

- Encrypted client protocol only; W&B connects with `tls = true`.
- Access-key authentication for compatibility with the current application images.
- `NoCluster` policy for standard Redis semantics across W&B components.
- High availability enabled.
- A private endpoint and disabled public access by default.

With `create_redis_private_endpoint = true`, the module creates the private
endpoint, the `privatelink.redis.azure.net` private DNS zone, and a VNet link.
W&B continues to use the normal Azure Redis hostname, which resolves to the
private IP inside the VNet. Set the option to `false` only when public Redis
network access is explicitly required.

Microsoft Entra authentication and clustered Redis are not enabled because the
current W&B image set expects a static Redis password and has not been validated
for token refresh or clustered routing across all components.

## Key Vault Network Access

`key_vault_network_access` supports `Public` and `Private`:

- `Public` is the default and allows Terraform to manage Key Vault keys and
  secrets from a laptop or hosted runner without VNet connectivity.
- `Private` disables public access and conditionally creates a dedicated subnet,
  private endpoint, `privatelink.vaultcore.azure.net` private DNS zone, and VNet
  link. The Terraform runner must have VNet, peered-network, or VPN connectivity
  to the private endpoint.

Private-endpoint networking resources are not created in Public mode. AKS KMS
receives the same network-access value so etcd encryption can reach Key Vault.

## TLS Certificates and Ingress

The module installs cert-manager `v1.21.0` with CRDs enabled through the current
`crds.enabled` chart value. The `cert-issuer` ClusterIssuer uses Let's Encrypt
and an HTTP-01 challenge through Azure Application Gateway.

Certificate issuance follows this flow:

```text
W&B Ingress -> cert-manager Certificate -> ACME Order and Challenge
             -> Application Gateway HTTP-01 route -> Let's Encrypt
             -> kubernetes.io/tls Secret -> Application Gateway HTTPS listener
```

Let's Encrypt is free and does not require a paid subscription. cert-manager
automatically renews the certificate and updates the Kubernetes TLS secret.

## Application Authentication Compatibility

The current deployment intentionally retains credential-based connections for
services that do not yet have a validated token-refresh flow across all W&B
containers:

- The staged CR template uses the `wandb-redis` Kubernetes Secret and TLS.
- The staged CR template uses the `wandb-mysql` Kubernetes Secret.
- The staged CR template uses the `wandb-license` Kubernetes Secret.
- Azure Storage uses an access key in the W&B specification while Workload
  Identity remains configured for components that support it.

External Secrets Operator or the Azure Key Vault Secrets Store CSI driver can
later automate population and rotation of the Kubernetes secrets without
changing their names or keys.

## Examples

We have included documentation and reference examples for additional common
installation scenarios for Weights & Biases, as well as examples for supporting
resources that lack official modules.

- [`examples/standard-tf`](examples/standard-tf) - Standard module deployment.
- [`examples/custom-tf-with-existing-resources`](examples/custom-tf-with-existing-resources) - Existing AKS and backing resources.
- [`examples/custom-tf-with-vpc-sql`](examples/custom-tf-with-vpc-sql) - Custom networking and SQL resources.
- [`examples/private-link`](examples/private-link) - Private Link integration.
- [`examples/public-dns`](examples/public-dns) - Public DNS integration.
- [`examples/secure-storage-connector`](examples/secure-storage-connector) - Workload Identity storage access.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.9 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.67 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.6 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.23 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | ~> 1.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.67 |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_app_aks"></a> [app\_aks](#module\_app\_aks) | ./modules/app_aks | n/a |
| <a name="module_app_lb"></a> [app\_lb](#module\_app\_lb) | ./modules/app_lb | n/a |
| <a name="module_cert_manager"></a> [cert\_manager](#module\_cert\_manager) | ./modules/cert_manager | n/a |
| <a name="module_clickhouse"></a> [clickhouse](#module\_clickhouse) | ./modules/clickhouse | n/a |
| <a name="module_cron_job"></a> [cron\_job](#module\_cron\_job) | ./modules/cron_job | n/a |
| <a name="module_database"></a> [database](#module\_database) | ./modules/database | n/a |
| <a name="module_identity"></a> [identity](#module\_identity) | ./modules/identity | n/a |
| <a name="module_networking"></a> [networking](#module\_networking) | ./modules/networking | n/a |
| <a name="module_pod_identity"></a> [pod\_identity](#module\_pod\_identity) | ./modules/identity | n/a |
| <a name="module_redis"></a> [redis](#module\_redis) | ./modules/redis | n/a |
| <a name="module_service_accounts"></a> [service\_accounts](#module\_service\_accounts) | ./modules/secure_storage_connector/service_accounts | n/a |
| <a name="module_storage"></a> [storage](#module\_storage) | ./modules/storage | n/a |
| <a name="module_vault"></a> [vault](#module\_vault) | ./modules/vault | n/a |
| <a name="module_wandb"></a> [wandb](#module\_wandb) | wandb/wandb/helm | 3.0.0 |

## Resources

| Name | Type |
|------|------|
| [azapi_resource_list.az_zones](https://registry.terraform.io/providers/azure/azapi/latest/docs/data-sources/resource_list) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_ip_ranges"></a> [allowed\_ip\_ranges](#input\_allowed\_ip\_ranges) | Allowed public IP addresses or CIDR ranges. | `list(string)` | `[]` | no |
| <a name="input_allowed_subscriptions"></a> [allowed\_subscriptions](#input\_allowed\_subscriptions) | List of allowed customer subscriptions coma seperated values | `string` | `""` | no |
| <a name="input_app_wandb_env"></a> [app\_wandb\_env](#input\_app\_wandb\_env) | Extra environment variables for W&B | `map(string)` | `{}` | no |
| <a name="input_azuremonitor"></a> [azuremonitor](#input\_azuremonitor) | # To support otel azure monitor sql and redis metrics need operator-wandb chart minimum version 0.14.0 | `bool` | `false` | no |
| <a name="input_blob_container"></a> [blob\_container](#input\_blob\_container) | Use an existing bucket. | `string` | `""` | no |
| <a name="input_bucket_path"></a> [bucket\_path](#input\_bucket\_path) | path of where to store data for the instance-level bucket | `string` | `""` | no |
| <a name="input_clickhouse_private_endpoint_service_name"></a> [clickhouse\_private\_endpoint\_service\_name](#input\_clickhouse\_private\_endpoint\_service\_name) | ClickHouse private endpoint 'Service name' (ends in .azure.privatelinkservice). | `string` | `""` | no |
| <a name="input_clickhouse_region"></a> [clickhouse\_region](#input\_clickhouse\_region) | ClickHouse region (eastus2, westus3, etc). | `string` | `""` | no |
| <a name="input_cluster_sku_tier"></a> [cluster\_sku\_tier](#input\_cluster\_sku\_tier) | The Azure AKS SKU Tier to use for this cluster (https://learn.microsoft.com/en-us/azure/aks/free-standard-pricing-tiers) | `string` | `"Free"` | no |
| <a name="input_controller_image_tag"></a> [controller\_image\_tag](#input\_controller\_image\_tag) | Tag of the controller image to deploy | `string` | `"1.20.0"` | no |
| <a name="input_create_private_link"></a> [create\_private\_link](#input\_create\_private\_link) | Use for the azure private link. | `bool` | `false` | no |
| <a name="input_create_redis"></a> [create\_redis](#input\_create\_redis) | Whether to provision an Azure Managed Redis instance. | `bool` | `true` | no |
| <a name="input_create_redis_private_endpoint"></a> [create\_redis\_private\_endpoint](#input\_create\_redis\_private\_endpoint) | Whether to disable Redis public access and create a private endpoint plus private DNS integration in the module VNet. | `bool` | `true` | no |
| <a name="input_database_availability_mode"></a> [database\_availability\_mode](#input\_database\_availability\_mode) | High-availability mode for Azure Database for MySQL Flexible Server. | `string` | `"SameZone"` | no |
| <a name="input_database_flags"></a> [database\_flags](#input\_database\_flags) | MySQL server parameters to set on the Azure Database for MySQL flexible server. Merged with W&B defaults. | `map(string)` | `{}` | no |
| <a name="input_database_sku_name"></a> [database\_sku\_name](#input\_database\_sku\_name) | Specifies the SKU Name for this MySQL Server. Defaults to null and value from deployment-size.tf is used | `string` | `null` | no |
| <a name="input_database_sort_buffer_size"></a> [database\_sort\_buffer\_size](#input\_database\_sort\_buffer\_size) | Specifies the sort\_buffer\_size value to set for the database | `number` | `524288` | no |
| <a name="input_database_version"></a> [database\_version](#input\_database\_version) | Azure Database for MySQL Flexible Server version. | `string` | `"8.4"` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | If the instance should have deletion protection enabled. The database / Bucket can't be deleted when this value is set to `true`. | `bool` | `true` | no |
| <a name="input_disable_storage_vault_key_id"></a> [disable\_storage\_vault\_key\_id](#input\_disable\_storage\_vault\_key\_id) | Flag to disable the `customer_managed_key` block, the properties 'encryption.identity, encryption.keyvaultproperties' cannot be updated in a single operation. | `bool` | `false` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Domain for accessing the Weights & Biases UI. | `string` | `null` | no |
| <a name="input_enable_database_vault_key"></a> [enable\_database\_vault\_key](#input\_enable\_database\_vault\_key) | Flag to enable managed key encryption for the database. Once enabled, cannot be disabled. | `bool` | `false` | no |
| <a name="input_enable_helm_operator"></a> [enable\_helm\_operator](#input\_enable\_helm\_operator) | Enable or disable applying and releasing W&B Operator chart | `bool` | `true` | no |
| <a name="input_enable_helm_wandb"></a> [enable\_helm\_wandb](#input\_enable\_helm\_wandb) | Enable or disable applying and releasing CR chart | `bool` | `true` | no |
| <a name="input_enable_storage_vault_key"></a> [enable\_storage\_vault\_key](#input\_enable\_storage\_vault\_key) | Flag to enable managed key encryption for the storage account. | `bool` | `false` | no |
| <a name="input_external_bucket"></a> [external\_bucket](#input\_external\_bucket) | config an external bucket | `any` | `null` | no |
| <a name="input_external_redis_host"></a> [external\_redis\_host](#input\_external\_redis\_host) | Hostname of the externally managed Redis instance. | `string` | `null` | no |
| <a name="input_external_redis_params"></a> [external\_redis\_params](#input\_external\_redis\_params) | Connection parameters passed to the W&B chart for an externally managed Redis instance. | `object({})` | `null` | no |
| <a name="input_external_redis_port"></a> [external\_redis\_port](#input\_external\_redis\_port) | Port of the externally managed Redis instance. | `string` | `null` | no |
| <a name="input_key_vault_network_access"></a> [key\_vault\_network\_access](#input\_key\_vault\_network\_access) | Key Vault data-plane network mode. Public permits access from an external Terraform runner; Private disables public access and creates a private endpoint, subnet, private DNS zone, and VNet link. | `string` | `"Public"` | no |
| <a name="input_kubernetes_cluster_tags"></a> [kubernetes\_cluster\_tags](#input\_kubernetes\_cluster\_tags) | A map of tags to apply to all resources managed by the AKS cluster | `map(string)` | `{}` | no |
| <a name="input_kubernetes_instance_type"></a> [kubernetes\_instance\_type](#input\_kubernetes\_instance\_type) | Instance type for primary node group. Defaults to null and value from deployment-size.tf is used | `string` | `null` | no |
| <a name="input_kubernetes_max_node_per_az"></a> [kubernetes\_max\_node\_per\_az](#input\_kubernetes\_max\_node\_per\_az) | Maximum number of nodes for the AKS cluster. Defaults to null and value from deployment-size.tf is used | `number` | `null` | no |
| <a name="input_kubernetes_min_node_per_az"></a> [kubernetes\_min\_node\_per\_az](#input\_kubernetes\_min\_node\_per\_az) | Minimum number of nodes for the AKS cluster. Defaults to null and value from deployment-size.tf is used | `number` | `null` | no |
| <a name="input_kubernetes_node_disk_size_gb"></a> [kubernetes\_node\_disk\_size\_gb](#input\_kubernetes\_node\_disk\_size\_gb) | Size of the node root volume in GB. | `number` | `null` | no |
| <a name="input_license"></a> [license](#input\_license) | Your wandb/local license | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | n/a | yes |
| <a name="input_lumen_agent_wif_audience"></a> [lumen\_agent\_wif\_audience](#input\_lumen\_agent\_wif\_audience) | the audience for a dedicated customer's WIF pool for a lumen agent | `string` | `""` | no |
| <a name="input_lumen_data_root"></a> [lumen\_data\_root](#input\_lumen\_data\_root) | object storage to which config data is written | `string` | `""` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | String used for prefix resources. | `string` | n/a | yes |
| <a name="input_node_max_pods"></a> [node\_max\_pods](#input\_node\_max\_pods) | Maximum number of pods per node | `number` | `30` | no |
| <a name="input_node_pool_num_zones"></a> [node\_pool\_num\_zones](#input\_node\_pool\_num\_zones) | Number of availability zones to use for the node pool when node\_pool\_zones is not set. If neither are set, 3 zones will be used | `number` | `2` | no |
| <a name="input_node_pool_zones"></a> [node\_pool\_zones](#input\_node\_pool\_zones) | Availability zones for the node pool | `list(string)` | `null` | no |
| <a name="input_oidc_auth_method"></a> [oidc\_auth\_method](#input\_oidc\_auth\_method) | OIDC auth method | `string` | `"implicit"` | no |
| <a name="input_oidc_client_id"></a> [oidc\_client\_id](#input\_oidc\_client\_id) | The Client ID of application in your identity provider | `string` | `""` | no |
| <a name="input_oidc_issuer"></a> [oidc\_issuer](#input\_oidc\_issuer) | A url to your Open ID Connect identity provider, i.e. https://cognito-idp.us-east-1.amazonaws.com/us-east-1_uiIFNdacd | `string` | `""` | no |
| <a name="input_oidc_secret"></a> [oidc\_secret](#input\_oidc\_secret) | The Client secret of application in your identity provider | `string` | `""` | no |
| <a name="input_operator_chart_version"></a> [operator\_chart\_version](#input\_operator\_chart\_version) | Version of the operator chart to deploy | `string` | `"1.4.2"` | no |
| <a name="input_other_wandb_env"></a> [other\_wandb\_env](#input\_other\_wandb\_env) | Extra environment variables for W&B | `map(any)` | `{}` | no |
| <a name="input_parquet_wandb_env"></a> [parquet\_wandb\_env](#input\_parquet\_wandb\_env) | Extra environment variables for W&B | `map(string)` | `{}` | no |
| <a name="input_redis_sku_name"></a> [redis\_sku\_name](#input\_redis\_sku\_name) | Azure Managed Redis SKU. When null, the selected deployment size determines the SKU. | `string` | `null` | no |
| <a name="input_size"></a> [size](#input\_size) | Deployment size | `string` | `"small"` | no |
| <a name="input_ssl"></a> [ssl](#input\_ssl) | Use HTTPS for the W&B application URL and ingress configuration. | `bool` | `true` | no |
| <a name="input_storage_account"></a> [storage\_account](#input\_storage\_account) | Azure storage account name | `string` | `""` | no |
| <a name="input_storage_key"></a> [storage\_key](#input\_storage\_key) | Azure primary storage access key | `string` | `""` | no |
| <a name="input_subdomain"></a> [subdomain](#input\_subdomain) | Optional subdomain for accessing the Weights & Biases UI. DNS records are managed outside this module. | `string` | `null` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Azure subscription ID | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags for resource | `map(string)` | `{}` | no |
| <a name="input_use_chainguard_redis"></a> [use\_chainguard\_redis](#input\_use\_chainguard\_redis) | Whether CHAINGUARD redis is deployed in the cluster | `bool` | `false` | no |
| <a name="input_use_ctrlplane_redis"></a> [use\_ctrlplane\_redis](#input\_use\_ctrlplane\_redis) | Whether redis is deployed in the cluster via ctrlplane | `bool` | `false` | no |
| <a name="input_use_dns_resolver"></a> [use\_dns\_resolver](#input\_use\_dns\_resolver) | [Internal Use Only] Skip the default cert-manager installation when an external DNS-01 certificate flow is provided. | `bool` | `false` | no |
| <a name="input_use_external_redis"></a> [use\_external\_redis](#input\_use\_external\_redis) | Use an externally managed Redis instance instead of the module-managed instance. | `bool` | `false` | no |
| <a name="input_use_internal_queue"></a> [use\_internal\_queue](#input\_use\_internal\_queue) | Use Redis for the internal queue instead of Azure Queue Storage. | `bool` | `false` | no |
| <a name="input_wandb_image"></a> [wandb\_image](#input\_wandb\_image) | Docker repository of to pull the wandb image from. | `string` | `"wandb/local"` | no |
| <a name="input_wandb_version"></a> [wandb\_version](#input\_wandb\_version) | The version of Weights & Biases local to deploy. | `string` | `"latest"` | no |
| <a name="input_weave_wandb_env"></a> [weave\_wandb\_env](#input\_weave\_wandb\_env) | Extra environment variables for W&B | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address"></a> [address](#output\_address) | n/a |
| <a name="output_aks_max_node_count"></a> [aks\_max\_node\_count](#output\_aks\_max\_node\_count) | n/a |
| <a name="output_aks_min_node_count"></a> [aks\_min\_node\_count](#output\_aks\_min\_node\_count) | n/a |
| <a name="output_aks_node_instance_type"></a> [aks\_node\_instance\_type](#output\_aks\_node\_instance\_type) | n/a |
| <a name="output_client_id"></a> [client\_id](#output\_client\_id) | n/a |
| <a name="output_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#output\_cluster\_ca\_certificate) | n/a |
| <a name="output_cluster_client_certificate"></a> [cluster\_client\_certificate](#output\_cluster\_client\_certificate) | n/a |
| <a name="output_cluster_client_key"></a> [cluster\_client\_key](#output\_cluster\_client\_key) | n/a |
| <a name="output_cluster_host"></a> [cluster\_host](#output\_cluster\_host) | n/a |
| <a name="output_database_instance_type"></a> [database\_instance\_type](#output\_database\_instance\_type) | n/a |
| <a name="output_fqdn"></a> [fqdn](#output\_fqdn) | The FQDN to the W&B application |
| <a name="output_oidc_issuer_url"></a> [oidc\_issuer\_url](#output\_oidc\_issuer\_url) | n/a |
| <a name="output_private_link_resource_id"></a> [private\_link\_resource\_id](#output\_private\_link\_resource\_id) | n/a |
| <a name="output_private_link_sub_resource_name"></a> [private\_link\_sub\_resource\_name](#output\_private\_link\_sub\_resource\_name) | n/a |
| <a name="output_standardized_size"></a> [standardized\_size](#output\_standardized\_size) | n/a |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | n/a |
| <a name="output_url"></a> [url](#output\_url) | The URL to the W&B application |
| <a name="output_wandb_spec"></a> [wandb\_spec](#output\_wandb\_spec) | n/a |
<!-- END_TF_DOCS -->

## Upgrading existing 7.x deployments

The Azure Managed Redis, networking, database, and cert-manager changes planned
for 8.x are not an automatic in-place upgrade. Follow the
[existing-customer migration guide](MIGRATION.md) before changing the module
version or applying a plan to existing infrastructure.

## Upgrading from 3.x to 4.x

3.0.0 introduced autoscaling to the AKS cluster and made the `size` variable the preferred way to set the cluster size.
Previously, unless the `size` variable was set explicitly, there were default values for the following variables:
- `kubernetes_instance_type`
- `kubernetes_node_count`
- `redis_sku_name`
- `database_sku_name`

The `size` variable is now defaulted to `small`, and the following values to can be used to partially override the values
set by the `size` variable:
- `kubernetes_instance_type`
- `kubernetes_min_node_per_az`
- `kubernetes_max_node_per_az`
- `redis_sku_name`
- `database_sku_name`

For more information on the available sizes, see the [Cluster Sizing](#cluster-sizing) section.

If having the cluster scale nodes in and out is not desired, the `kubernetes_min_node_per_az` and 
`kubernetes_max_node_per_az` can be set to the same value to prevent the cluster from scaling.

### Upgrading from 2.x to 3.x

When upgrading from 2.x to 3.x, the following changes are required:

1. Add the `azapi` provider to the `required_providers` block:

```hcl
terraform {
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.0"
    }
  }
}
```

2. Add the `azapi` provider to the `provider` block:

```hcl
provider "azapi" {
    # azapi provider configuration should be the same as azurerm provider configuration
}
```
