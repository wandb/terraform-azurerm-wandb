variable "secrets_store_csi_driver_version" {
  type        = string
  description = "The version of the Secrets Store CSI Driver Helm chart to install"
}

variable "azure_provider_manifest_body" {
  type        = string
  description = "The raw YAML content of the Azure Key Vault Provider manifest"
}
