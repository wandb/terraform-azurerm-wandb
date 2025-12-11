# Provider configurations for when this module is used as a root module
# These will be ignored when used as a child module

provider "azurerm" {
  features {}
}

provider "kubernetes" {
  host                   = module.app_aks.cluster_host
  cluster_ca_certificate = base64decode(module.app_aks.cluster_ca_certificate)
  client_key             = base64decode(module.app_aks.cluster_client_key)
  client_certificate     = base64decode(module.app_aks.cluster_client_certificate)
}

provider "helm" {
  kubernetes {
    host                   = module.app_aks.cluster_host
    cluster_ca_certificate = base64decode(module.app_aks.cluster_ca_certificate)
    client_key             = base64decode(module.app_aks.cluster_client_key)
    client_certificate     = base64decode(module.app_aks.cluster_client_certificate)
  }
}

provider "kubectl" {
  host                   = module.app_aks.cluster_host
  cluster_ca_certificate = base64decode(module.app_aks.cluster_ca_certificate)
  client_key             = base64decode(module.app_aks.cluster_client_key)
  client_certificate     = base64decode(module.app_aks.cluster_client_certificate)
  load_config_file       = false
}
