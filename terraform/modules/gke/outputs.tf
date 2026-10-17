output "cluster_name" {
  value = google_container_cluster.this.name
}

output "cluster_location" {
  value = google_container_cluster.this.location
}

output "node_pool_name" {
  value = google_container_node_pool.primary.name
}

output "private_endpoint" {
  value = google_container_cluster.this.private_cluster_config[0].private_endpoint
}

output "public_endpoint" {
  value = google_container_cluster.this.endpoint
}
