module "compute" {
  source = "../../modules/compute"

  project_id   = var.project_id
  project_name = var.project_name
  environment  = var.environment
  zone         = var.zone

  network_name            = module.network.network_name
  devops_subnet_self_link = module.network.devops_subnet_self_link
  devops_subnet_cidr      = var.devops_subnet_cidr

  admin_cidr = var.admin_cidr

  ssh_user       = var.ssh_user
  ssh_public_key = var.ssh_public_key

  jenkins_controller_service_account = module.iam.jenkins_controller_email
  jenkins_agent_service_account      = module.iam.jenkins_agent_email
  sonarqube_service_account          = module.iam.sonarqube_email

  jenkins_controller_machine_type = var.jenkins_controller_machine_type
  jenkins_agent_machine_type      = var.jenkins_agent_machine_type
  sonarqube_machine_type          = var.sonarqube_machine_type
}
