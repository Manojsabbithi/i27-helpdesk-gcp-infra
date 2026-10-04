locals {
  common_labels = {
    project     = var.project_name
    environment = var.environment
    managed_by  = "terraform"
  }
}

# ---------------------------------------------------------
# Docker repositories
# ---------------------------------------------------------

resource "google_artifact_registry_repository" "services" {
  for_each = var.services

  project       = var.project_id
  location      = var.region
  repository_id = "${var.project_name}-${var.environment}-${each.value}"

  description = "Docker repository for ${each.value} (${var.environment})"

  format = "DOCKER"

  docker_config {
    immutable_tags = false
  }

  labels = merge(local.common_labels, {
    service = each.value
  })
}


# ---------------------------------------------------------
# Jenkins Agent - push images
# ---------------------------------------------------------

resource "google_artifact_registry_repository_iam_member" "jenkins_writer" {
  for_each = var.services

  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.services[each.key].name

  role = "roles/artifactregistry.writer"

  member = "serviceAccount:${var.jenkins_agent_service_account}"
}
