variable "namespace" {
  type        = string
  description = "Friendly name prefix used for tagging and naming Azure resources."
}

variable "resource_group" {
  type        = object({ name = string, id = string })
  description = "Resource Group where the Managed Kubernetes Cluster should exist."
}

variable "location" {
  type        = string
  description = "The location where the Managed Kubernetes Cluster should be created."
}

variable "cluster_subnet_id" {
  type        = string
  description = "Network subnet id for cluster"
}

variable "gateway" {
  type = object({ id = string })
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "Map of tags for resource"
}

variable "use_azure_defender" {
  default     = false
  type        = bool
  description = "Either uses Microsoft Defender for Containers or not. If true, the attribute `input_log_analytics_workspace_id` need to be supplied."
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log analytics ID for cluster where Microsoft Defender for Containers feature is enabled"
}
