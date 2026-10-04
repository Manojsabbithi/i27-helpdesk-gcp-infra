output "jenkins_controller_name" {
  value = google_compute_instance.jenkins_controller.name
}

output "jenkins_controller_private_ip" {
  value = google_compute_instance.jenkins_controller.network_interface[0].network_ip
}

output "jenkins_controller_public_ip" {
  value = google_compute_instance.jenkins_controller.network_interface[0].access_config[0].nat_ip
}

output "jenkins_agent_name" {
  value = google_compute_instance.jenkins_agent.name
}

output "jenkins_agent_private_ip" {
  value = google_compute_instance.jenkins_agent.network_interface[0].network_ip
}

output "jenkins_agent_public_ip" {
  value = google_compute_instance.jenkins_agent.network_interface[0].access_config[0].nat_ip
}

output "sonarqube_name" {
  value = google_compute_instance.sonarqube.name
}

output "sonarqube_private_ip" {
  value = google_compute_instance.sonarqube.network_interface[0].network_ip
}

output "sonarqube_public_ip" {
  value = google_compute_instance.sonarqube.network_interface[0].access_config[0].nat_ip
}
