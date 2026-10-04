module "network" {
  source = "../../modules/network"

  project_id   = var.project_id
  project_name = var.project_name
  environment  = var.environment
  region       = var.region

  devops_subnet_cidr      = var.devops_subnet_cidr
  gke_subnet_cidr         = var.gke_subnet_cidr
  gke_pods_range_cidr     = var.gke_pods_range_cidr
  gke_services_range_cidr = var.gke_services_range_cidr
  private_services_cidr   = var.private_services_cidr

  admin_cidr = var.admin_cidr
}
