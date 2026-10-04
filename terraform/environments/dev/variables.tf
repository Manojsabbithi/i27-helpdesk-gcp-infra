variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "project_name" {
  description = "Short project name used in resource names."
  type        = string
  default     = "i27-helpdesk"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"
}

variable "region" {
  description = "Primary GCP region."
  type        = string
}

variable "zone" {
  description = "Primary GCP zone."
  type        = string
}

variable "devops_subnet_cidr" {
  description = "CIDR for Jenkins and SonarQube Compute Engine instances."
  type        = string
}

variable "gke_subnet_cidr" {
  description = "Primary CIDR for GKE nodes."
  type        = string
}

variable "gke_pods_range_cidr" {
  description = "Secondary CIDR used for Kubernetes Pods."
  type        = string
}

variable "gke_services_range_cidr" {
  description = "Secondary CIDR used for Kubernetes Services."
  type        = string
}

variable "private_services_cidr" {
  description = "CIDR reserved for Google managed services such as Cloud SQL."
  type        = string
}

variable "admin_cidr" {
  description = "Administrator public IP in /32 format."
  type        = string
}
