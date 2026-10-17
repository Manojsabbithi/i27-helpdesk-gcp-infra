locals {
  cluster_name = "${var.project_name}-${var.environment}-gke"

  common_labels = {
    project     = var.project_name
    environment = var.environment
    managed_by  = "terraform"
  }
}

# ---------------------------------------------------------
# GKE Standard Cluster
# ---------------------------------------------------------

resource "google_container_cluster" "this" {
  project  = var.project_id
  name     = local.cluster_name
  location = var.zone

  network    = var.network_name
  subnetwork = var.subnetwork_self_link

  networking_mode = "VPC_NATIVE"

  remove_default_node_pool = true
  initial_node_count       = 1

  deletion_protection   = false
  enable_shielded_nodes = true

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = var.admin_cidr
      display_name = "administrator"
    }
  }

  release_channel {
    channel = "REGULAR"
  }

  resource_labels = local.common_labels
}

# ---------------------------------------------------------
# Cost-conscious development node pool
# ---------------------------------------------------------

resource "google_container_node_pool" "primary" {
  project  = var.project_id
  name     = "${local.cluster_name}-nodes"
  location = var.zone
  cluster  = google_container_cluster.this.name

  node_count = var.node_count

  node_config {
    machine_type = var.node_machine_type
    disk_type    = "pd-balanced"
    disk_size_gb = 30
    image_type   = "COS_CONTAINERD"

    service_account = var.node_service_account

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    labels = local.common_labels

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }

  lifecycle {
    ignore_changes = [
      node_count
    ]
  }
}
