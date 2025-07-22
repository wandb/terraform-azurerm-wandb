# Weights & Biases Secure Storage Connector Example

This is an example of how to use the Weights & Biases Secure Storage Connector module for Azure, to create a storage account and container. The module also creates a managed identity (with federated credentials) used to auth to the container.

## Prerequisites

- Terraform ~> 1.0
- Azure CLI installed and configured
- An existing Azure Resource Group
- A deployed W&B instance AKS cluster with OIDC enabled

## Azure Services Used

- Microsoft Entra ID (formerly Azure Active Directory)
- Azure Blob Storage

## Usage

1. Clone this repository
2. Navigate to this example directory
3. Create a `terraform.tfvars` file with your values:

```hcl
subscription_id     = "your-subscription-id"
tenant_id          = "your-tenant-id"
namespace          = "your-namespace"
resource_group_name = "your-resource-group"
oidc_issuer_url    = "the-deployment's-aks-oidc-issuer-url"  # Make sure to include trailing '/'
deletion_protection = <true or false>
```

4. Initialize Terraform:
```bash
terraform init
```

5. Apply the configuration:
```bash
terraform apply
```

## Important Notes

- Make sure to include the trailing '/' in the OIDC issuer URL
- The resource group must already exist before applying this configuration
- The namespace will be used as a prefix for all created resources

## Outputs

After applying the configuration, you'll get the following outputs:

- `storage_account_name`: The name of the created storage account
- `storage_container_name`: The name of the created storage container
- `managed_identity_client_id`: The Client ID of the created Managed Identity
- `tenant_id`: The Tenant ID of the Azure Directory

Use these values when configuring the bucket in the Weights & Biases Create Team UI panel.

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| subscription_id | The Azure Subscription ID where resources will be created | string | - | yes |
| tenant_id | The Azure Tenant ID where resources will be created | string | - | yes |
| namespace | Prefix to use when creating resources | string | - | yes |
| resource_group_name | The name of the resource group in which to create the managed identity and storage account | string | - | yes |
| oidc_issuer_url | OIDC issuer URL from the AKS cluster that is meant to connect to this container | string | - | yes |
| deletion_protection | If the instance should have deletion protection enabled | bool | false | no |