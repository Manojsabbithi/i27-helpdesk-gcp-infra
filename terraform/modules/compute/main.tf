locals {
  common_labels = {
    project     = "i27-helpdesk"
    environment = var.environment
    managed_by  = "terraform"
  }
}

# ---------------------------------------------------------
# Jenkins Controller
# ---------------------------------------------------------

resource "google_compute_instance" "jenkins_controller" {
  project      = var.project_id
  zone         = var.zone
  name         = "${var.project_name}-${var.environment}-jenkins-controller"
  machine_type = var.jenkins_controller_machine_type

  allow_stopping_for_update = true

  tags = [
    "i27-devops",
    "jenkins-controller"
  ]

  labels = merge(local.common_labels, {
    role = "jenkins-controller"
  })

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2404-lts-amd64"
      size  = 20
      type  = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = var.devops_subnet_self_link

    # Ephemeral external IPv4.
    access_config {}
  }

  service_account {
    email = var.jenkins_controller_service_account

    scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }
}


# ---------------------------------------------------------
# Jenkins Agent
# ---------------------------------------------------------

resource "google_compute_instance" "jenkins_agent" {
  project      = var.project_id
  zone         = var.zone
  name         = "${var.project_name}-${var.environment}-jenkins-agent"
  machine_type = var.jenkins_agent_machine_type

  allow_stopping_for_update = true

  tags = [
    "i27-devops",
    "jenkins-agent"
  ]

  labels = merge(local.common_labels, {
    role = "jenkins-agent"
  })

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2404-lts-amd64"
      size  = 30
      type  = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = var.devops_subnet_self_link

    access_config {}
  }

  service_account {
    email = var.jenkins_agent_service_account

    scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }
}


# ---------------------------------------------------------
# SonarQube
# ---------------------------------------------------------

resource "google_compute_instance" "sonarqube" {
  project      = var.project_id
  zone         = var.zone
  name         = "${var.project_name}-${var.environment}-sonarqube"
  machine_type = var.sonarqube_machine_type

  allow_stopping_for_update = true

  tags = [
    "i27-devops",
    "sonarqube"
  ]

  labels = merge(local.common_labels, {
    role = "sonarqube"
  })

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2404-lts-amd64"
      size  = 30
      type  = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = var.devops_subnet_self_link

    access_config {}
  }

  service_account {
    email = var.sonarqube_service_account

    scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }
}


# ---------------------------------------------------------
# Jenkins Web UI
# ---------------------------------------------------------

resource "google_compute_firewall" "jenkins_ui" {
  project = var.project_id

  name      = "${var.project_name}-${var.environment}-allow-jenkins-ui"
  network   = var.network_name
  direction = "INGRESS"
  priority  = 1000

  source_ranges = [
    var.admin_cidr
  ]

  target_tags = [
    "jenkins-controller"
  ]

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  description = "Allow Jenkins UI only from administrator public IP."
}


# ---------------------------------------------------------
# SonarQube Web UI
# ---------------------------------------------------------

resource "google_compute_firewall" "sonarqube_ui" {
  project = var.project_id

  name      = "${var.project_name}-${var.environment}-allow-sonarqube-ui"
  network   = var.network_name
  direction = "INGRESS"
  priority  = 1000

  source_ranges = [
    var.admin_cidr
  ]

  target_tags = [
    "sonarqube"
  ]

  allow {
    protocol = "tcp"
    ports    = ["9000"]
  }

  description = "Allow SonarQube UI only from administrator public IP."
}


# ---------------------------------------------------------
# Internal SSH between DevOps hosts
# Required for Jenkins Controller -> Jenkins Agent
# ---------------------------------------------------------

resource "google_compute_firewall" "devops_internal_ssh" {
  project = var.project_id

  name      = "${var.project_name}-${var.environment}-allow-devops-internal-ssh"
  network   = var.network_name
  direction = "INGRESS"
  priority  = 1000

  source_ranges = [
    var.devops_subnet_cidr
  ]

  target_tags = [
    "i27-devops"
  ]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  description = "Allow SSH between DevOps hosts over private networking."
}
# ---------------------------------------------------------
# Jenkins -> SonarQube over private VPC
# Used by Jenkins CI for SonarQube analysis
# ---------------------------------------------------------

resource "google_compute_firewall" "jenkins_to_sonarqube" {
  project = var.project_id

  name      = "${var.project_name}-${var.environment}-allow-jenkins-to-sonarqube"
  network   = var.network_name
  direction = "INGRESS"
  priority  = 1000

  source_tags = [
    "jenkins-agent",
    "jenkins-controller"
  ]

  target_tags = [
    "sonarqube"
  ]

  allow {
    protocol = "tcp"
    ports    = ["9000"]
  }

  description = "Allow Jenkins hosts to access SonarQube over private networking."
}
