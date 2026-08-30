locals {
  issuer_name       = "${var.namespace}-letsencrypt"
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
    # cert-manager v1.15+ uses crds.enabled; the legacy installCRDs value is no
    # longer used by current chart versions.
    name  = "crds.enabled"
    value = true
  }
}

# Install the local ClusterIssuer chart only after the cert-manager CRDs and
# webhook are available. The issuer registers an ACME account and configures the
# Azure Application Gateway ingress class for HTTP-01 validation.
resource "helm_release" "cert_issuer" {
  name       = "cert-issuer"
  chart      = "cert-issuer"
  repository = path.module
  namespace  = local.default_namespace

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

  depends_on = [helm_release.cert_manager]
}
