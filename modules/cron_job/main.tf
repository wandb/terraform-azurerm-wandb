resource "helm_release" "cron_job" {
  name       = "jobs"
  chart      = "jobs"
  repository = path.module
  values = [
    <<EOT
    namespace: ${var.namespace} 
    client_id: ${var.client_id}
    serviceaccountName: "${var.serviceaccountName}"
    subscriptionId: "${var.subscriptionId}"
    resourceGroupName: "${var.resourceGroupName}"
    applicationGatewayName: "${var.applicationGatewayName}"
    allowedSubscriptions: "${var.allowedSubscriptions}"
    EOT 
  ]
}
