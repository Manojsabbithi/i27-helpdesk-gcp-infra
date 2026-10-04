output "network_name" {
  value = google_compute_network.this.name
}

output "network_id" {
  value = google_compute_network.this.id
}

output "network_self_link" {
  value = google_compute_network.this.self_link
}

output "devops_subnet_name" {
  value = google_compute_subnetwork.devops.name
}

output "devops_subnet_id" {
  value = google_compute_subnetwork.devops.id
}

output "devops_subnet_self_link" {
  value = google_compute_subnetwork.devops.self_link
}

output "gke_subnet_name" {
  value = google_compute_subnetwork.gke.name
}

output "gke_subnet_id" {
  value = google_compute_subnetwork.gke.id
}

output "gke_subnet_self_link" {
  value = google_compute_subnetwork.gke.self_link
}

output "gke_pods_range_name" {
  value = local.gke_pods_range_name
}

output "gke_services_range_name" {
  value = local.gke_services_range_name
}

output "private_services_range_name" {
  value = google_compute_global_address.private_services.name
}

output "private_service_peering" {
  value = google_service_networking_connection.private_services.peering
}
