locals {
  default_namespace = "default"
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  chart            = "cert-manager"
  repository       = "https://charts.jetstack.io"
  version          = var.cert_manager_chart_version
  namespace        = local.default_namespace
  create_namespace = true

  set {
    name  = "installCRDs"
    value = true
  }
}