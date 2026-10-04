resource "google_service_account" "jenkins_controller" {
  project      = var.project_id
  account_id   = "i27-${var.environment}-jenkins-controller"
  display_name = "i27 Jenkins Controller ${var.environment}"
  description  = "Service account attached to the Jenkins Controller VM."
}

resource "google_service_account" "jenkins_agent" {
  project      = var.project_id
  account_id   = "i27-${var.environment}-jenkins-agent"
  display_name = "i27 Jenkins Agent ${var.environment}"
  description  = "Service account attached to the Jenkins build agent VM."
}

resource "google_service_account" "sonarqube" {
  project      = var.project_id
  account_id   = "i27-${var.environment}-sonarqube"
  display_name = "i27 SonarQube ${var.environment}"
  description  = "Service account attached to the SonarQube VM."
}

resource "google_service_account" "gke_nodes" {
  project      = var.project_id
  account_id   = "i27-${var.environment}-gke-nodes"
  display_name = "i27 GKE Nodes ${var.environment}"
  description  = "Custom least-privilege service account for GKE nodes."
}

resource "google_service_account" "attachment" {
  project      = var.project_id
  account_id   = "i27-${var.environment}-attachment"
  display_name = "i27 Attachment Workload ${var.environment}"
  description  = "Google service account used by attachment-service through GKE Workload Identity."
}

resource "google_service_account" "notification" {
  project      = var.project_id
  account_id   = "i27-${var.environment}-notification"
  display_name = "i27 Notification Workload ${var.environment}"
  description  = "Google service account used by notification-service through GKE Workload Identity."
}


# ---------------------------------------------------------
# Jenkins Controller - observability
# ---------------------------------------------------------

resource "google_project_iam_member" "jenkins_controller_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.jenkins_controller.email}"
}

resource "google_project_iam_member" "jenkins_controller_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.jenkins_controller.email}"
}


# ---------------------------------------------------------
# Jenkins Agent - observability
# ---------------------------------------------------------

resource "google_project_iam_member" "jenkins_agent_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.jenkins_agent.email}"
}

resource "google_project_iam_member" "jenkins_agent_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.jenkins_agent.email}"
}


# ---------------------------------------------------------
# SonarQube - observability
# ---------------------------------------------------------

resource "google_project_iam_member" "sonarqube_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.sonarqube.email}"
}

resource "google_project_iam_member" "sonarqube_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.sonarqube.email}"
}


# ---------------------------------------------------------
# GKE Node identity
# ---------------------------------------------------------

resource "google_project_iam_member" "gke_default_node_role" {
  project = var.project_id
  role    = "roles/container.defaultNodeServiceAccount"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}
