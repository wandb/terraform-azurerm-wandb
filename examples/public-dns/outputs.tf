output "address" {
  value = module.wandb.address
}

output "aks_node_count" {
  value = module.wandb.aks_node_count
}

output "aks_node_instance_type" {
  value = module.wandb.aks_node_instance_type
}

output "database_instance_type" {
  value = module.wandb.database_instance_type
}

output "redis_instance_type" {
  value = module.wandb.redis_instance_type
}

output "standardized_size" {
  value = var.size
}

output "url" {
  value = module.wandb.url
}
