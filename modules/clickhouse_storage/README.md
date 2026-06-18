# ClickHouse Storage Module

This module provisions an Azure Storage Account and container for ClickHouse data storage, along with the necessary managed identity and RBAC permissions for Kubernetes workload identity integration.

## Features

- Creates a dedicated Azure Storage Account for ClickHouse data
- Provisions a blob container for storing ClickHouse tables and data
- Configures proper CORS rules for blob access
- Optional deletion protection via management locks
- Supports configurable replication types (LRS, GRS, ZRS, etc.)

## Usage

```hcl
module "clickhouse_storage" {
  source              = "./modules/clickhouse_storage"
  namespace           = "my-deployment"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  container_name      = "clickhouse-data"
  replication_type    = "ZRS"
  deletion_protection = true
  tags                = var.tags
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| namespace | Friendly name prefix used for tagging and naming Azure resources | `string` | n/a | yes |
| resource_group_name | The name of the resource group | `string` | n/a | yes |
| location | The Azure location where resources will be created | `string` | n/a | yes |
| container_name | Name of the blob container for ClickHouse data | `string` | `"clickhouse-data"` | no |
| replication_type | Storage account replication type | `string` | `"ZRS"` | no |
| deletion_protection | Enable deletion protection | `bool` | `false` | no |
| tags | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| storage_account | The storage account resource |
| storage_container | The storage container resource |
| storage_account_name | The storage account name |
| container_name | The container name |
| primary_access_key | The primary access key (sensitive) |
| primary_blob_endpoint | The primary blob endpoint URL |

## Storage Account Naming

The storage account name is automatically generated based on:
- Your namespace (special characters removed, truncated to fit Azure's 24-character limit)
- A "clickhouse" postfix

Example: namespace `wandb-prod-eastus` becomes `wandbprodeastusclickhouse`
