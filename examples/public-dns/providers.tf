terraform {
  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.30"
    }
    # helm = {
    #   source  = "hashicorp/helm"
    #   version = "~> 2.6"
    # }
    # kubernetes = {
    #   source  = "hashicorp/kubernetes"
    #   version = "~> 2.23"
    # }
  }
}
