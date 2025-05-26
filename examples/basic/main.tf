#----------------------------------------------------------------------------
# Basic Example - Simple GitHub Repository (FIXED)
#----------------------------------------------------------------------------

module "basic_repository" {
  source = "../.."

  # Basic repository settings
  name        = "basic-example-repo"
  description = "A basic example repository created with OpenTofu"
  visibility  = "private"

  # Repository features
  has_issues   = true
  has_projects = false
  has_wiki     = false

  # Topics for discoverability
  topics = ["example", "basic", "demo"]

  # Basic merge settings
  allow_merge_commit = true
  allow_squash_merge = true
  allow_rebase_merge = false

  delete_branch_on_merge = true

  # Security
  vulnerability_alerts = true
}

#----------------------------------------------------------------------------
# Outputs
#----------------------------------------------------------------------------

output "repository_url" {
  description = "The URL of the created repository"
  value       = module.basic_repository.html_url
}

output "repository_clone_url" {
  description = "The SSH clone URL"
  value       = module.basic_repository.ssh_clone_url
}

output "repository_name" {
  description = "The name of the repository"
  value       = module.basic_repository.repository_name
}
