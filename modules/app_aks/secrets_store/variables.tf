variable "secrets_store_csi_driver_version" {
  type        = string
  description = "The version of the Secrets Store CSI Driver Helm chart to install"
  default     = "1.4.7"
}

variable "secrets_store_csi_driver_provider_azure_version" {
  type        = string
  description = "The version of the Azure Key Vault Provider for Secrets Store CSI Driver to install"
  default     = "1.7.1"
}
