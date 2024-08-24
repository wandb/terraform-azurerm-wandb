output "clickhouse_private_link_guid" {
  value       = jsondecode(data.azapi_resource.clickhouse_private_endpoint_guid.output).properties.resourceGuid
  description = "ClickHouse Private Link GUID"
}
