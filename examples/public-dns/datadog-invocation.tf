variable "dd_api_key" {
  nullable = true
  type     = string
}
variable "dd_app_key" {
  nullable = true
  type     = string
}
variable "dd_site" {
  nullable = true
  type     = string
}


 module "datadog" {
   #source             = "git::https://github.com/wandb/terraform-wandb-modules.git//datadog?ref=working"
   source = "../../../terraform-wandb-modules/datadog/"
   cloud_provider_tag = "azure"
   cluster_name       = module.wandb.cluster_id
   database_tag       = "managed"
   api_key            = var.dd_api_key
   app_key            = var.dd_app_key
   site               = var.dd_site
   environment_tag    = "managed-install"
   k8s_cluster_ca_certificate = base64decode(module.wandb.cluster_ca_certificate)
   k8s_host                   = module.wandb.cluster_host
   k8s_token                  = null
   k8s_client_certificate     = base64decode(module.wandb.cluster_client_certificate)
   k8s_client_key             = base64decode(module.wandb.cluster_client_key)
   

   namespace       = var.namespace
   objectstore_tag = "managed"
}



# provider "kubernetes" {
#   host = "https://${google_container_cluster.primary.endpoint}"
#   username = "${google_container_cluster.primary.master_auth.0.username}"
#   password = "${google_container_cluster.primary.master_auth.0.password}"
#   client_certificate = "${base64decode(google_container_cluster.primary.master_auth.0.client_certificate)}"
#   client_key = "${base64decode(google_container_cluster.primary.master_auth.0.client_key)}"
#   cluster_ca_certificate = "${base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)}"
# }