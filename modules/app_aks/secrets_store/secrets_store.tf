# Install Secrets Store CSI Driver via Helm
resource "helm_release" "secrets_store_csi_driver" {
  name       = "secrets-store-csi-driver"
  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart      = "secrets-store-csi-driver"
  version    = var.secrets_store_csi_driver_version
  namespace  = "kube-system"

  set {
    name  = "syncSecret.enabled"
    value = "true"
  }

  set {
    name  = "enableSecretRotation"
    value = "true"
  }

  set {
    name  = "rotationPollInterval"
    value = "120s"
  }

  set {
    name  = "tokenRequests[0].audience"
    value = "api://AzureADTokenExchange"
  }
}

# Install Azure Key Vault Provider for Secrets Store CSI Driver
# NOTE: Manifest is fetched at parent level to ensure early evaluation in Terraform Cloud
locals {
  azure_provider_manifests = [
    for manifest in split("---", var.azure_provider_manifest_body) :
    manifest
    if trimspace(manifest) != "" && can(yamldecode(manifest))
  ]
}

resource "kubectl_manifest" "azure_provider" {
  for_each = { for idx, manifest in local.azure_provider_manifests : idx => manifest }

  yaml_body = each.value

  server_side_apply = true
  wait              = true

  depends_on = [
    helm_release.secrets_store_csi_driver
  ]
}

# NOTE: The SecretProviderClass is created by the application Helm chart (operator-wandb),
# not by Terraform. This avoids CRD timing issues and keeps application-specific configuration
# with the application deployment.
