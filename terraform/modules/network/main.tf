locals {
  network_name = "${var.project_name}-${var.environment}-vpc"

  devops_subnet_name = "${var.project_name}-${var.environment}-devops-subnet"
  gke_subnet_name    = "${var.project_name}-${var.environment}-gke-subnet"

  gke_pods_range_name     = "${var.project_name}-${var.environment}-gke-pods"
  gke_services_range_name = "${var.project_name}-${var.environment}-gke-services"

  private_services_range_name = "google-managed-services-${local.network_name}"
}

resource "google_compute_network" "this" {
  project = var.project_id

  name                    = local.network_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"

  description = "Custom VPC for the i27 Helpdesk ${var.environment} environment."
}

resource "google_compute_subnetwork" "devops" {
  project = var.project_id
  region  = var.region

  name          = local.devops_subnet_name
  network       = google_compute_network.this.id
  ip_cidr_range = var.devops_subnet_cidr

  private_ip_google_access = true

  description = "Subnet for Jenkins Controller, Jenkins Agent and SonarQube."
}

resource "google_compute_subnetwork" "gke" {
  project = var.project_id
  region  = var.region

  name          = local.gke_subnet_name
  network       = google_compute_network.this.id
  ip_cidr_range = var.gke_subnet_cidr

  private_ip_google_access = true

  secondary_ip_range {
    range_name    = local.gke_pods_range_name
    ip_cidr_range = var.gke_pods_range_cidr
  }

  secondary_ip_range {
    range_name    = local.gke_services_range_name
    ip_cidr_range = var.gke_services_range_cidr
  }

  description = "Subnet and secondary ranges for GKE."
}

resource "google_compute_global_address" "private_services" {
  project = var.project_id

  name          = local.private_services_range_name
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = cidrhost(var.private_services_cidr, 0)
  prefix_length = tonumber(split("/", var.private_services_cidr)[1])

  network = google_compute_network.this.id
}

resource "google_service_networking_connection" "private_services" {
  network = google_compute_network.this.id
  service = "servicenetworking.googleapis.com"

  reserved_peering_ranges = [
    google_compute_global_address.private_services.name
  ]
}

resource "google_compute_firewall" "admin_ssh" {
  project = var.project_id

  name      = "${var.project_name}-${var.environment}-allow-admin-ssh"
  network   = google_compute_network.this.name
  direction = "INGRESS"
  priority  = 1000

  source_ranges = [
    var.admin_cidr
  ]

  target_tags = [
    "i27-devops"
  ]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  description = "Allow SSH to DevOps hosts only from the current administrator public IP."
}
