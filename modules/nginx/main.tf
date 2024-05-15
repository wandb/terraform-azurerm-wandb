resource "helm_release" "nginx" {
  name       = "nginx"
  chart      = "nginx"
  repository = path.module
}
