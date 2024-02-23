provider "helm" {
  debug = true
  kubernetes {
    host                   = module.app_aks.cluster.kube_config.0.host
    client_certificate     = base64decode(module.app_aks.cluster.kube_config.0.client_certificate)
    client_key             = base64decode(module.app_aks.cluster.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(module.app_aks.cluster.kube_config.0.cluster_ca_certificate)
  }
}