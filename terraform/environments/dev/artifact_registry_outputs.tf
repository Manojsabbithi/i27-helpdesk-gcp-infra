output "artifact_registry_host" {
  value = module.artifact_registry.registry_host
}

output "artifact_registry_repositories" {
  value = module.artifact_registry.repository_names
}

output "artifact_registry_urls" {
  value = module.artifact_registry.repository_urls
}
