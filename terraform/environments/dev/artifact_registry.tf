module "artifact_registry" {
  source = "../../modules/artifact-registry"

  project_id   = var.project_id
  project_name = var.project_name
  environment  = var.environment
  region       = var.region

  services = [
    "ui-service",
    "gateway-service",
    "auth-service",
    "ticket-service",
    "comment-service",
    "notification-service",
    "attachment-service"
  ]

  jenkins_agent_service_account = module.iam.jenkins_agent_email
}
