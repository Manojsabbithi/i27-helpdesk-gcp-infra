variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "project_name" {
  description = "Project naming prefix."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "region" {
  description = "GCP region for Artifact Registry."
  type        = string
}

variable "services" {
  description = "Microservices requiring Docker repositories."
  type        = set(string)
}

variable "jenkins_agent_service_account" {
  description = "Jenkins Agent Google service account email."
  type        = string
}
