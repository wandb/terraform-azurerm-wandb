# ClickHouse Application Module

This module deploys a complete ClickHouse cluster on Azure Kubernetes Service (AKS) with:
- Altinity ClickHouse Operator
- ClickHouse Keeper (Zookeeper replacement) for coordination
- ClickHouse cluster with Azure Blob Storage backend
- Azure Workload Identity integration

## Architecture

The deployment consists of:
1. **ClickHouse Operator**: Manages ClickHouse installations via CRDs
2. **ClickHouse Keeper**: 3-node cluster for coordination and replication
3. **ClickHouse Server**: 3-node replicated cluster with 1 shard
4. **Azure Blob Storage**: Backend storage with local disk cache (40Gi cache, 50Gi PVC)

## Features

- **High Availability**: 3 replicas for both ClickHouse and Keeper
- **Azure Blob Storage**: Data stored in Azure Blob with local cache layer
- **Workload Identity**: Secure authentication to Azure storage via workload identity
- **Pod Anti-Affinity**: Ensures replicas run on different nodes
- **Configurable Resources**: CPU and memory settings for both ClickHouse and Keeper

## Usage

```hcl
module "clickhouse_app" {
  source                       = "./modules/clickhouse_app"
  namespace                    = "clickhouse"
  clickhouse_replicas          = 3
  storage_account_name         = "mystorageaccount"
  storage_container_name       = "clickhouse-data"
  clickhouse_identity_client_id = "00000000-0000-0000-0000-000000000000"
  service_account_name         = "clickhouse"

  # Optional: Customize resources
  clickhouse_memory_request    = "2Gi"
  clickhouse_memory_limit      = "16Gi"
  clickhouse_cpu_request       = "1"
  clickhouse_cpu_limit         = "2"
}
```

## Storage Configuration

The module uses a hybrid storage approach:
- **Azure Blob Storage**: Primary storage backend (unlimited capacity)
- **Local Disk Cache**: 50Gi PVC with 40Gi usable cache for performance
- **Storage Classes**:
  - Data: `managed-csi-premium` (Azure Premium SSD)
  - Logs: `managed-csi` (Azure Standard Disk)

### Storage Policy

Data is stored using the `azure_main` storage policy:
- Writes go to Azure Blob Storage
- Reads are cached locally (40Gi cache)
- Cache eviction uses LRU policy
- `cache_on_write_operations` is enabled

## Credentials

- **Username**: `weave`
- **Password**: `clickhouse123` (stored in `ch-db` Kubernetes secret)

## Endpoints

After deployment, ClickHouse is accessible at:
- **Native Protocol**: `chi-wandb-ch-clickhouse-0-0.clickhouse.svc.cluster.local:9000`
- **HTTP Interface**: `chi-wandb-ch-clickhouse-0-0.clickhouse.svc.cluster.local:8123`
- **Load Balanced Service**: `clickhouse-wandb-ch.clickhouse.svc.cluster.local`

## Connection Example

```bash
# Using clickhouse-client
clickhouse-client \
  --host=chi-wandb-ch-clickhouse-0-0.clickhouse.svc.cluster.local \
  --port=9000 \
  --user=weave \
  --password=clickhouse123

# Using HTTP interface
curl -u weave:clickhouse123 \
  'http://chi-wandb-ch-clickhouse-0-0.clickhouse.svc.cluster.local:8123/?query=SELECT%20version()'
```

## Distributed Queries

The cluster is configured with a remote cluster named `weave_cluster` for distributed queries:

```sql
-- Create a distributed table
CREATE TABLE my_table_dist AS my_table_local
ENGINE = Distributed(weave_cluster, default, my_table_local, rand());
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| namespace | Kubernetes namespace | `string` | `"clickhouse"` | no |
| clickhouse_replicas | Number of replicas | `number` | `3` | no |
| clickhouse_image | ClickHouse server image | `string` | `"clickhouse/clickhouse-server:25.3.5.42"` | no |
| keeper_image | ClickHouse Keeper image | `string` | `"clickhouse/clickhouse-keeper:25.3.5.42"` | no |
| clickhouse_memory_request | Memory request | `string` | `"2Gi"` | no |
| clickhouse_memory_limit | Memory limit | `string` | `"16Gi"` | no |
| clickhouse_cpu_request | CPU request | `string` | `"1"` | no |
| clickhouse_cpu_limit | CPU limit | `string` | `"2"` | no |
| keeper_memory_request | Keeper memory request | `string` | `"256M"` | no |
| keeper_memory_limit | Keeper memory limit | `string` | `"4Gi"` | no |
| keeper_cpu_request | Keeper CPU request | `string` | `"1"` | no |
| keeper_cpu_limit | Keeper CPU limit | `string` | `"2"` | no |
| storage_account_name | Azure storage account name | `string` | n/a | yes |
| storage_container_name | Azure container name | `string` | n/a | yes |
| clickhouse_identity_client_id | Workload identity client ID | `string` | n/a | yes |
| service_account_name | K8s service account name | `string` | `"clickhouse"` | no |
| operator_chart_version | Operator Helm chart version | `string` | `"0.25.4"` | no |

## Outputs

| Name | Description |
|------|-------------|
| namespace | Kubernetes namespace |
| service_account_name | K8s service account name |
| clickhouse_endpoint | Native protocol endpoint |
| clickhouse_http_endpoint | HTTP endpoint |
| clickhouse_service | Service name (load balanced) |
| clickhouse_username | ClickHouse username |
| clickhouse_password_secret | K8s secret name containing password |
| keeper_endpoints | Keeper endpoint addresses |
| cluster_name | Cluster name |
| remote_cluster_name | Remote cluster name for distributed queries |

## Dependencies

This module requires:
1. AKS cluster with OIDC issuer enabled
2. Azure storage account and container (created by `clickhouse_storage` module)
3. Azure managed identity with storage permissions (created by `clickhouse_identity` module)

## Notes

- First deployment may take 5-10 minutes as images are pulled and pods start
- Keeper must be fully running before ClickHouse pods start
- Storage class names may vary by cluster configuration
- Verify with: `kubectl get chi,chk -n clickhouse`
