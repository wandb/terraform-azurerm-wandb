# Staging Server: https://acme-staging-v02.api.letsencrypt.org/directory
# Production Server: "https://acme-v02.api.letsencrypt.org/directory"
variable "namespace" {
  type = string
}

variable "acme_server" {
  type        = string
  description = "The acme server to use. ACME Production server: https://acme-v02.api.letsencrypt.org/directory and ACME Staging: https://acme-staging-v02.api.letsencrypt.org/directory"
  default     = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "cert_manager_email" {
  type        = string
  default     = "sysadmin@wandb.com"
  description = "Email to be used for ACME"
}

variable "cert_manager_chart_version" {
  type        = string
  description = "The version of Cert-manager to install"
}

variable "ingress_class" {
  type        = string
  description = "The ingress class to monitor for ingress"
  default     = "azure/application-gateway"
}
