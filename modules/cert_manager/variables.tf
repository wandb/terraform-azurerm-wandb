# Staging Server: https://acme-staging-v02.api.letsencrypt.org/directory
# Production Server: "https://acme-v02.api.letsencrypt.org/directory"
variable "namespace" {
  type = string
}

variable "acme_server" {
  type        = string
  description = "ACME directory URL. Use Let's Encrypt staging while testing issuance and production for trusted certificates."
  default     = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "cert_manager_email" {
  type        = string
  default     = "sysadmin@wandb.com"
  description = "Contact email registered with the ACME account."
}

variable "cert_manager_chart_version" {
  type        = string
  description = "cert-manager Helm chart version to install."
}

variable "ingress_class" {
  type        = string
  description = "Ingress class used by the ACME HTTP-01 solver."
  default     = "azure/application-gateway"
}

variable "tags" {
  description = "Tags to be passed to created instances"
  default     = {}
}
