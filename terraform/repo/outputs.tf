#----------------------------------------------------------------------------
# outputs.tf - OpenTofu GitHub Repository Module
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# Repository Outputs
#----------------------------------------------------------------------------

output "repository_id" {
  description = "The ID of the created repository."
  value       = github_repository.repository.id
}

output "repository_name" {
  description = "The name of the created repository."
  value       = github_repository.repository.name
}

output "repository_full_name" {
  description = "The full name of the created repository (owner/name)."
  value       = github_repository.repository.full_name
}

output "repository_description" {
  description = "The description of the created repository."
  value       = github_repository.repository.description
}

output "repository_visibility" {
  description = "The visibility of the created repository."
  value       = github_repository.repository.visibility
}

output "repository_default_branch" {
  description = "The default branch of the created repository."
  value       = github_repository.repository.default_branch
}

#----------------------------------------------------------------------------
# Repository URLs
#----------------------------------------------------------------------------

output "html_url" {
  description = "The URL of the created repository."
  value       = github_repository.repository.html_url
}

output "ssh_clone_url" {
  description = "The SSH clone URL of the created repository."
  value       = github_repository.repository.ssh_clone_url
}

output "http_clone_url" {
  description = "The HTTP clone URL of the created repository."
  value       = github_repository.repository.http_clone_url
}

output "git_clone_url" {
  description = "The git clone URL of the created repository."
  value       = github_repository.repository.git_clone_url
}

output "svn_url" {
  description = "The Subversion clone URL of the created repository."
  value       = github_repository.repository.svn_url
}

#----------------------------------------------------------------------------
# Repository Properties
#----------------------------------------------------------------------------

output "repository_node_id" {
  description = "The Node ID of the created repository."
  value       = github_repository.repository.node_id
}

output "repository_topics" {
  description = "The topics assigned to the repository."
  value       = github_repository.repository.topics
}

output "repository_archived" {
  description = "Whether the repository is archived."
  value       = github_repository.repository.archived
}

output "repository_private" {
  description = "Whether the repository is private."
  value       = github_repository.repository.private
}

#----------------------------------------------------------------------------
# GitHub Pages
#----------------------------------------------------------------------------

output "pages_url" {
  description = "The URL of the repository's GitHub Pages site."
  value       = try(github_repository.repository.pages[0].html_url, null)
}

output "pages_status" {
  description = "The status of the repository's GitHub Pages site."
  value       = try(github_repository.repository.pages[0].status, null)
}

output "pages_cname" {
  description = "The custom domain of the repository's GitHub Pages site."
  value       = try(github_repository.repository.pages[0].cname, null)
}

#----------------------------------------------------------------------------
# Team and Collaborator Information
#----------------------------------------------------------------------------

output "team_permissions" {
  description = "The team permissions configured for the repository."
  value = {
    for team_slug, permission in var.team_permissions :
    team_slug => {
      permission = permission
      team_id    = data.github_team.team_ids[team_slug].id
      team_name  = data.github_team.team_ids[team_slug].name
    }
  }
}

output "collaborator_permissions" {
  description = "The collaborator permissions configured for the repository."
  value = {
    for username, permission in var.collaborator_permissions :
    username => {
      permission = permission
      user_id    = data.github_user.collaborators[username].id
    }
  }
}

#----------------------------------------------------------------------------
# Branch Information
#----------------------------------------------------------------------------

output "branches" {
  description = "Information about the branches created for the repository."
  value = {
    default_branch = github_repository.repository.default_branch
    protected_branches = [
      for branch_name, protection_config in var.branch_protection :
      branch_name
    ]
    additional_branches = [
      for branch in github_branch.branches :
      branch.branch
    ]
  }
}

output "branch_protection_rules" {
  description = "Information about branch protection rules."
  value = {
    for rule in github_branch_protection.protection :
    rule.pattern => {
      pattern                         = rule.pattern
      required_status_checks_strict   = try(rule.required_status_checks[0].strict, null)
      required_status_checks_contexts = try(rule.required_status_checks[0].contexts, null)
      enforce_admins                  = rule.enforce_admins
      allows_deletions                = rule.allows_deletions
      allows_force_pushes            = rule.allows_force_pushes
    }
  }
}

#----------------------------------------------------------------------------
# Repository Rulesets Information
#----------------------------------------------------------------------------

output "repository_rulesets" {
  description = "Information about repository rulesets."
  value = {
    for ruleset in github_repository_ruleset.rulesets :
    ruleset.name => {
      id          = ruleset.id
      name        = ruleset.name
      target      = ruleset.target
      enforcement = ruleset.enforcement
      node_id     = ruleset.node_id
    }
  }
}

#----------------------------------------------------------------------------
# Deploy Keys Information
#----------------------------------------------------------------------------

output "deploy_keys" {
  description = "Information about deploy keys."
  value = {
    for key in github_repository_deploy_key.deploy_keys :
    key.title => {
      id        = key.id
      title     = key.title
      read_only = key.read_only
    }
  }
}

#----------------------------------------------------------------------------
# Webhooks Information
#----------------------------------------------------------------------------

output "webhooks" {
  description = "Information about repository webhooks."
  value = {
    for webhook_name, webhook in github_repository_webhook.webhooks :
    webhook_name => {
      id     = webhook.id
      url    = webhook.url
      active = webhook.active
      events = webhook.events
    }
  }
}

#----------------------------------------------------------------------------
# Environments Information
#----------------------------------------------------------------------------

output "environments" {
  description = "Information about repository environments."
  value = {
    for env in github_repository_environment.environments :
    env.environment => {
      id                  = env.id
      environment         = env.environment
      wait_timer          = env.wait_timer
      can_admins_bypass   = env.can_admins_bypass
      prevent_self_review = env.prevent_self_review
    }
  }
}

#----------------------------------------------------------------------------
# Repository Files Information  
#----------------------------------------------------------------------------

output "repository_files" {
  description = "Information about files added to the repository."
  value = {
    for file_path, file in github_repository_file.files :
    file_path => {
      file           = file.file
      commit_sha     = file.commit_sha
      commit_message = file.commit_message
      branch         = file.branch
    }
  }
}

#----------------------------------------------------------------------------
# Security Information
#----------------------------------------------------------------------------

output "security_and_analysis" {
  description = "Security and analysis settings for the repository."
  value = var.security_and_analysis != null ? {
    advanced_security_enabled           = try(var.security_and_analysis.advanced_security.status == "enabled", false)
    secret_scanning_enabled            = try(var.security_and_analysis.secret_scanning.status == "enabled", false)
    secret_scanning_push_protection    = try(var.security_and_analysis.secret_scanning_push_protection.status == "enabled", false)
  } : null
}

output "vulnerability_alerts_enabled" {
  description = "Whether vulnerability alerts are enabled for the repository."
  value       = github_repository.repository.vulnerability_alerts
}