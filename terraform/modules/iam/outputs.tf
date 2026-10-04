output "jenkins_controller_email" {
  value = google_service_account.jenkins_controller.email
}

output "jenkins_agent_email" {
  value = google_service_account.jenkins_agent.email
}

output "sonarqube_email" {
  value = google_service_account.sonarqube.email
}

output "gke_nodes_email" {
  value = google_service_account.gke_nodes.email
}

output "attachment_email" {
  value = google_service_account.attachment.email
}

output "notification_email" {
  value = google_service_account.notification.email
}
