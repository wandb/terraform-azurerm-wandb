output "issuer" {
  value       = local.issuer_name
  description = "Name of the Issuer to be used in annotations"
}

output "cert_manager_namespace" {
  description = "The kubernetes namespace of the cert-manager release"
  value       = var.byoc ? null : helm_release.cert_manager[0].namespace
}

output "cert_manager_release_name" {
  description = "Name of the Cert Manager release"
  value       = var.byoc ? null : helm_release.cert_manager[0].name
}
