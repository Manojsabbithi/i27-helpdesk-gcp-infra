output "network_name" {
  value = module.network.network_name
}

output "devops_subnet_name" {
  value = module.network.devops_subnet_name
}

output "gke_subnet_name" {
  value = module.network.gke_subnet_name
}

output "gke_pods_range_name" {
  value = module.network.gke_pods_range_name
}

output "gke_services_range_name" {
  value = module.network.gke_services_range_name
}

output "private_services_range_name" {
  value = module.network.private_services_range_name
}

output "private_service_peering" {
  value = module.network.private_service_peering
}
