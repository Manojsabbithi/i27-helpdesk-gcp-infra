output "jenkins_controller_service_account" {
  value = module.iam.jenkins_controller_email
}

output "jenkins_agent_service_account" {
  value = module.iam.jenkins_agent_email
}

output "sonarqube_service_account" {
  value = module.iam.sonarqube_email
}

output "gke_nodes_service_account" {
  value = module.iam.gke_nodes_email
}

output "attachment_service_account" {
  value = module.iam.attachment_email
}

output "notification_service_account" {
  value = module.iam.notification_email
}
