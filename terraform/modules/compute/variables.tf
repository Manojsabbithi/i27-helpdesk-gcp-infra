variable "project_id" {
  type = string
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "zone" {
  type = string
}

variable "network_name" {
  type = string
}

variable "devops_subnet_self_link" {
  type = string
}

variable "devops_subnet_cidr" {
  type = string
}

variable "admin_cidr" {
  type = string
}

variable "ssh_user" {
  type = string
}

variable "ssh_public_key" {
  type      = string
  sensitive = true
}

variable "jenkins_controller_service_account" {
  type = string
}

variable "jenkins_agent_service_account" {
  type = string
}

variable "sonarqube_service_account" {
  type = string
}

variable "jenkins_controller_machine_type" {
  type    = string
  default = "e2-small"
}

variable "jenkins_agent_machine_type" {
  type    = string
  default = "e2-medium"
}

variable "sonarqube_machine_type" {
  type    = string
  default = "e2-medium"
}
