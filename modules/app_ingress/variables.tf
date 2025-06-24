variable "fqdn" {
  type        = string
  description = "Fully qualified domain name."
}

variable "namespace" {
  type = string
}

variable "use_dns_challenge" {
  type        = bool
  description = "Should be used in conjuction with the cert_manager's modules variable"
  default     = false
}
