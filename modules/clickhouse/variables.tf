variable "namespace" {
  type        = string
  description = "Friendly name prefix used for tagging and naming Azure resources."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the network."
}

variable "private_subnet_id" {
  type        = string
  description = "Specifies the supported Azure subnet id where the resource exists."
}

locals {
  clickhouse_private_endpoint_validation = (
    (var.clickhouse_private_endpoint_service_name == "" && var.clickhouse_private_endpoint_dns_name == "") ||
    (var.clickhouse_private_endpoint_service_name != "" && var.clickhouse_private_endpoint_dns_name != "")
  )
}

variable "clickhouse_private_endpoint_validation_check" {
  type    = bool
  default = local.clickhouse_private_endpoint_validation

  validation {
    condition     = var.clickhouse_private_endpoint_validation_check
    error_message = "Both 'clickhouse_private_endpoint_service_name' and 'clickhouse_private_endpoint_dns_name' must be set together, or both must be empty."
  }
}

variable "clickhouse_private_endpoint_service_name" {
  description = "ClickHouse private endpoint 'Service name' (ends in .azure.privatelinkservice)."
  type        = string
  default     = ""

  validation {
    condition = (
      var.clickhouse_private_endpoint_service_name == "" ||
      can(regex("^[^.]+\\.[^.]+\\.azure\\.privatelinkservice$", var.clickhouse_private_endpoint_service_name))
    )
    error_message = "ClickHouse Service name must be in the format '<HOSTNAME>.<REGION>.azure.privatelinkservice'."
  }
}

variable "clickhouse_private_endpoint_dns_name" {
  description = "ClickHouse private endpoint 'DNS name' (ends in .privatelink.azure.clickhouse.cloud)."
  type        = string
  default     = ""

  validation {
    condition = (
      var.clickhouse_private_endpoint_dns_name == "" ||
      can(regex("^[^.]+\\.[^.]+\\.privatelink\\.azure\\.clickhouse\\.cloud$", var.clickhouse_private_endpoint_dns_name))
    )
    error_message = "ClickHouse DNS name must be in the format '<HOSTNAME>.<REGION>.privatelink.azure.clickhouse.cloud'."
  }
}
