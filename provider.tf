variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

provider "azapi" {
  subscription_id = var.subscription_id
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