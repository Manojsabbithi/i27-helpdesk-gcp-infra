output "repository_names" {
  value = {
    for service, repository in google_artifact_registry_repository.services :
    service => repository.repository_id
  }
}

output "repository_urls" {
  value = {
    for service, repository in google_artifact_registry_repository.services :
    service => "${var.region}-docker.pkg.dev/${var.project_id}/${repository.repository_id}"
  }
}

output "registry_host" {
  value = "${var.region}-docker.pkg.dev"
}
