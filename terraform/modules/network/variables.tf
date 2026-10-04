variable "project_id" {
  type = string
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "devops_subnet_cidr" {
  type = string
}

variable "gke_subnet_cidr" {
  type = string
}

variable "gke_pods_range_cidr" {
  type = string
}

variable "gke_services_range_cidr" {
  type = string
}

variable "private_services_cidr" {
  type = string
}

variable "admin_cidr" {
  type = string
}
