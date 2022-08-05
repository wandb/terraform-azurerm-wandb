locals {
  issuer_name = "${var.namespace}-letsencrypt"
}

resource "helm_release" "default" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = true
  }
}

# Cert Issuer using Helm
resource "helm_release" "default" {
  name       = "cert-issuer"
  repository = path.module
  chart      = "cert-issuer"
  namespace  = var.namespace

  set {
    name  = "fullnameOverride"
    value = local.issuer_name
  }

  set {
    name  = "privateKeySecretRef"
    value = local.issuer_name
  }

  set {
    name  = "ingressClass"
    value = var.ingress_class
  }

  set {
    name  = "acmeEmail"
    value = var.cert_manager_email
  }

  set {
    name  = "acmeServer"
    value = var.acme_server
  }

  depends_on = [helm_release.default]
}
