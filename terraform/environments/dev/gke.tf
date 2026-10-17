module "gke" {
  source = "../../modules/gke"

  project_id   = var.project_id
  project_name = var.project_name
  environment  = var.environment
  zone         = var.zone

  network_name         = module.network.network_name
  subnetwork_self_link = module.network.gke_subnet_self_link

  pods_range_name     = module.network.gke_pods_range_name
  services_range_name = module.network.gke_services_range_name

  node_service_account = module.iam.gke_nodes_email

  admin_cidr = var.admin_cidr

  node_machine_type      = "e2-standard-2"
  node_count             = 1
  master_ipv4_cidr_block = "172.16.0.0/28"
}
