locals {
  deployment_is_private = false
  ssl_certificate_name  = null
  tls_secret_name       = "wandb-ssl-cert"
  host                  = trimprefix(trimprefix(var.fqdn, "https://"), "http://")
  service_name          = "wandb"
  service_port          = 8080
}

resource "kubernetes_ingress_v1" "default" {
  wait_for_load_balancer = true
  
  metadata {
    name = "wandb"
    annotations = {
      "kubernetes.io/ingress.class"                       = "azure/application-gateway"
      "appgw.ingress.kubernetes.io/appgw-ssl-certificate" = local.ssl_certificate_name
      "appgw.ingress.kubernetes.io/use-private-ip"        = local.deployment_is_private ? "true" : null
      "cert-manager.io/cluster-issuer"                    = local.deployment_is_private ? null : "cert-issuer"
      "cert-manager.io/acme-challenge-type"               = local.deployment_is_private ? null : "http01"
    }
  }
  spec {
    tls {
      hosts       = local.deployment_is_private ? null : [local.host]
      secret_name = local.deployment_is_private ? null : local.tls_secret_name
    }

    default_backend {
      service {
        name = local.service_name
        port {
          number = local.service_port
        }
      }
    }

    rule {
      http {
        path {
          path = "/"
          backend {
            service {
              name = local.service_name
              port {
                number = local.service_port
              }
            }
          }
        }
      }
    }

    rule {
      host = local.host
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = local.service_name
              port {
                number = local.service_port
              }
            }
          }
        }
      }
    }
  }
}
