# Existing-customer migration guide

## Upgrading from 7.x to 8.x

Version 8.x is intended for new deployments and is a breaking change for
existing 7.x deployments. It replaces Azure Cache for Redis with Azure Managed
Redis and also updates database, certificate-management, provider, and network
defaults.

Do not upgrade an existing production deployment by changing the module version
and immediately running `terraform apply`. Complete the assessment and staged
cutover below first.

This guide applies to deployments in which this module manages AKS and its
Azure backing services. Deployments using external Redis, MySQL, Key Vault, or
other custom resources require an environment-specific migration plan.

## Summary of breaking changes

| Area | 7.x | 8.x | Existing-customer impact |
|------|-----|-----|--------------------------|
| Redis service | `azurerm_redis_cache` | `azurerm_managed_redis` | A different Azure resource is created; this is not an in-place Terraform move. |
| Redis sizing | `redis_capacity` | `redis_sku_name` | Calling configurations must replace the removed input. |
| Redis transport | Non-TLS was available | Encrypted client protocol | Application connections and health checks must use TLS. |
| Redis networking | Public endpoint | Private endpoint by default | AKS must resolve and reach the private endpoint. |
| Redis topology | Legacy cache configuration | High availability with `NoCluster` | Preserves non-clustered Redis client behavior but changes the service endpoint and credentials. |
| MySQL default | 5.7 | 8.4 in the current 8.x draft | Pin the existing version during the infrastructure migration and validate any database upgrade separately with W&B. |
| cert-manager | v1.9.1 | v1.21.0 | Review the supported cert-manager upgrade path and verify issuers and certificates after upgrading. |
| AzureRM provider | `~> 4.26` | `~> 4.67` | Provider schema changes may produce additional plan differences. |
| Storage queue settings | Inline `queue_properties` | Separate queue-properties resource | Expected to update management of the same queue service; any proposed storage-account replacement is unexpected. |
| Key Vault network | Public | Public by default; Private is optional | Private mode requires the Terraform runner to have private network and DNS access. |

The current W&B infrastructure requirements specify MySQL 8.0.x. Do not move an
existing database to 8.4 until the target W&B release and Azure database upgrade
path have been confirmed with W&B Support. See the
[W&B infrastructure requirements](https://docs.wandb.ai/platform/hosting/self-managed/requirements).

## 1. Pin the existing release

Keep the production deployment on an exact 7.x version until the migration has
been tested:

```hcl
module "wandb" {
  source  = "wandb/wandb/azurerm"
  version = "7.9.2"

  # Existing inputs...
}
```

Avoid referencing `main`, an untagged Git source, or a version range that can
select the next major release. Terraform does not record remote module versions
in `.terraform.lock.hcl`.

## 2. Capture the current configuration and recovery points

Run these commands from the existing deployment workspace:

```bash
terraform init
terraform validate
terraform plan -out=tfplan-before-v8
terraform state pull > terraform-state-before-v8.json
terraform output
```

Terraform plans, state, and outputs can contain credentials. Store these files
in an approved encrypted location and do not commit them.

Before continuing:

- Confirm that the current Terraform plan is empty or explain every difference.
- Confirm that Azure Database for MySQL point-in-time restore is available and
  record the current server version.
- Record the current Redis hostname, port, SKU, and network configuration
  without placing access keys in the migration document.
- Confirm that the W&B license, MySQL, Redis, and storage credentials can be
  recovered from their authoritative secret stores.
- Export the cert-manager `ClusterIssuer`, `Certificate`, and TLS Secret names.
- Confirm the rollback owner, maintenance window, and application validation
  checks.

## 3. Update the calling configuration without applying

Replace the removed Redis input and explicitly retain the existing database
version for the first infrastructure plan:

```hcl
module "wandb" {
  source  = "wandb/wandb/azurerm"
  version = "8.0.0"

  redis_sku_name              = "Balanced_B10"
  create_redis_private_endpoint = true

  # Do not combine the module migration with a MySQL major-version upgrade.
  database_version = "<CURRENT_DATABASE_VERSION>"

  # Public supports a laptop or hosted runner without VNet connectivity.
  key_vault_network_access = "Public"
}
```

If Key Vault Private mode is required, first move the Terraform runner onto a
network that can resolve and reach the Key Vault private endpoint. Do not select
Private mode from a laptop or runner that only has public connectivity.

Update the root provider configuration and lock file deliberately:

```bash
terraform init -upgrade
terraform providers
terraform validate
terraform plan -out=tfplan-v8-review
terraform show tfplan-v8-review
```

Do not apply if the plan proposes replacement of AKS, MySQL, Storage, Key Vault,
or Application Gateway unless that replacement is explicitly part of the
approved migration.

## 4. Migrate Redis as a controlled cutover

Terraform cannot use a `moved` block to convert `azurerm_redis_cache` into
`azurerm_managed_redis`; they are different Azure resource types. The module
does not automate Redis data migration or a zero-downtime cutover.

Use this sequence:

1. Provision Azure Managed Redis from a separate transition stack with the
   selected SKU, encrypted client protocol, `NoCluster`, high availability, a
   private endpoint, and private DNS. Select a name that can be retained by the
   final module configuration and confirm Azure naming availability first.
2. From an AKS test pod, verify that the normal Managed Redis hostname resolves
   to a private address and that a TLS-authenticated connection succeeds.
3. Confirm with W&B Support whether any Redis-resident queues or transient data
   must be drained or preserved for the deployed application version.
4. Schedule a maintenance window and stop or quiesce writers and workers when
   required by that guidance.
5. Update the Redis Kubernetes Secret and W&B connection values with the new
   hostname, TLS port, access key, and `tls = true`.
6. Reconcile the W&B Custom Resource and verify application, worker, queue, and
   Redis health before restoring traffic.
7. Before applying 8.x, prevent Terraform from automatically deleting the
   legacy cache. Use a reviewed state-transition procedure (or a module-provided
   `removed` block with `destroy = false`) and retain the pre-migration state
   backup. Do not run ad-hoc state commands without confirming the exact address
   with `terraform state list`.
8. Import the replacement Managed Redis resource and its private endpoint into
   their final 8.x Terraform addresses. Confirm that the plan updates the
   application connection but neither recreates the replacement nor deletes
   the legacy cache.
9. Retain the legacy Azure Cache for Redis until the application has passed the
   agreed validation period. Remove it only through a separately approved plan.

Do not place Redis access keys in Git, saved plans, tickets, or migration logs.

## 5. Upgrade cert-manager separately

The cert-manager change spans multiple releases. Treat it as a separate
operational checkpoint rather than combining certificate troubleshooting with
the Redis cutover.

Before and after the upgrade, check:

```bash
kubectl get crd | grep cert-manager
kubectl get clusterissuer
kubectl get certificate,certificaterequest,order,challenge -A
kubectl get pods -n cert-manager
```

After reconciliation, verify that:

- cert-manager and its webhook are Ready.
- The `cert-issuer` ClusterIssuer is Ready.
- The W&B Certificate is Ready.
- The expected Kubernetes TLS Secret exists.
- HTTPS through Azure Application Gateway presents the expected trusted
  certificate.

Follow the cert-manager project's supported upgrade documentation if an
intermediate release is required for the versions in the environment.

## 6. Handle the storage queue resource transition

The queue logging configuration moves from the deprecated inline storage
account block to `azurerm_storage_account_queue_properties`.

Review the plan for an in-place queue-service configuration update. Stop if it
proposes replacing the storage account, container, or stored W&B objects. If an
existing queue-properties object must be imported, use the resource ID and
import procedure reported by the AzureRM provider for the selected version;
never remove the storage account from state to suppress the plan.

## 7. Validate the application end to end

At minimum, verify:

```bash
kubectl get weightsandbiases,pods,services,ingress,certificate -A
kubectl get events -A --sort-by=.lastTimestamp
```

Also verify:

- User login and the W&B UI.
- Run creation and metric logging.
- Artifact upload and download through Azure Storage.
- Background job and internal queue processing.
- MySQL connectivity and application migrations.
- Redis TLS connectivity and the absence of authentication or cluster-routing
  errors.
- HTTPS certificate issuance and renewal status.
- Application and worker logs for errors.

Keep the old Redis service and recovery points until these checks pass and the
rollback window has closed.

## 8. Upgrade MySQL only as a separate project

Do not change the MySQL major version during the Redis/module migration. After
the infrastructure upgrade is stable:

1. Confirm the MySQL version supported by the target W&B Server release.
2. Review Azure's supported Flexible Server major-version upgrade path.
3. Test a point-in-time-restored copy with the target W&B version.
4. Take a fresh recovery point and schedule a database maintenance window.
5. Perform and validate the database upgrade independently.

Changing Terraform state does not roll back an Azure database upgrade.

## Rollback boundaries

- Reverting the module version can restore Terraform configuration, but it does
  not restore data or reverse an Azure service migration.
- A Terraform state backup records resource mappings; it is not a Redis, MySQL,
  Storage, or Key Vault data backup.
- Keep the old Redis service available until the new endpoint is validated.
- Do not roll MySQL back by editing Terraform state. Use the approved Azure
  restore procedure.
- If Key Vault is switched to Private mode, restore runner connectivity before
  attempting any Terraform rollback that accesses the vault data plane.

## Completion criteria

The migration is complete only when:

- The final Terraform plan contains no unexplained changes.
- Azure Managed Redis is reachable privately over TLS and public access matches
  the approved design.
- All W&B application checks pass.
- cert-manager, the issuer, and the W&B certificate are Ready.
- The legacy Redis service has been removed through a reviewed plan.
- Recovery files and temporary credentials have been handled according to the
  organization's retention policy.
