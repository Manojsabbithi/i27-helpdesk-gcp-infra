output "gke_cluster_name" {
  value = module.gke.cluster_name
}

output "gke_cluster_location" {
  value = module.gke.cluster_location
}

output "gke_node_pool_name" {
  value = module.gke.node_pool_name
}

output "gke_private_endpoint" {
  value = module.gke.private_endpoint
}

output "gke_public_endpoint" {
  value = module.gke.public_endpoint
}
