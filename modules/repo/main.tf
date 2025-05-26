#----------------------------------------------------------------------------
# main.tf - OpenTofu GitHub Repository Module
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# data
#----------------------------------------------------------------------------

data "github_team" "team_ids" {
  for_each = var.team_permissions
  slug     = each.key
}

data "github_user" "collaborators" {
  for_each = var.collaborator_permissions
  username = each.key
}

#----------------------------------------------------------------------------
# locals
#----------------------------------------------------------------------------

locals {
  has_template = var.template != null
  # Merge default and custom topics, remove duplicates
  all_topics = distinct(concat(var.default_topics, var.topics))

  # Convert sensitive map to non-sensitive keys for for_each
  repository_secret_keys = var.repository_secrets != null ? keys(var.repository_secrets) : []
}

#----------------------------------------------------------------------------
# Repository
#----------------------------------------------------------------------------

resource "github_repository" "repository" {
  name         = var.name
  description  = var.description
  visibility   = var.visibility
  has_issues   = var.has_issues
  has_projects = var.has_projects
  has_wiki     = var.has_wiki

  auto_init          = var.auto_init && !local.has_template
  gitignore_template = local.has_template ? null : var.gitignore_template
  license_template   = local.has_template ? null : var.license_template

  allow_merge_commit          = var.allow_merge_commit
  allow_squash_merge          = var.allow_squash_merge
  allow_rebase_merge          = var.allow_rebase_merge
  allow_auto_merge            = var.allow_auto_merge
  squash_merge_commit_title   = var.squash_merge_commit_title
  squash_merge_commit_message = var.squash_merge_commit_message
  merge_commit_title          = var.merge_commit_title
  merge_commit_message        = var.merge_commit_message

  vulnerability_alerts        = var.vulnerability_alerts
  delete_branch_on_merge      = var.delete_branch_on_merge
  allow_update_branch         = var.allow_update_branch
  web_commit_signoff_required = var.web_commit_signoff_required

  # Archive settings
  archived           = var.archived
  archive_on_destroy = var.archive_on_destroy

  # Homepage
  homepage_url = var.homepage_url

  topics = local.all_topics

  # Security and analysis
  dynamic "security_and_analysis" {
    for_each = var.security_and_analysis != null ? [var.security_and_analysis] : []
    content {
      dynamic "advanced_security" {
        for_each = security_and_analysis.value.advanced_security != null ? [security_and_analysis.value.advanced_security] : []
        content {
          status = advanced_security.value.status
        }
      }
      dynamic "secret_scanning" {
        for_each = security_and_analysis.value.secret_scanning != null ? [security_and_analysis.value.secret_scanning] : []
        content {
          status = secret_scanning.value.status
        }
      }
      dynamic "secret_scanning_push_protection" {
        for_each = security_and_analysis.value.secret_scanning_push_protection != null ? [security_and_analysis.value.secret_scanning_push_protection] : []
        content {
          status = secret_scanning_push_protection.value.status
        }
      }
    }
  }

  # GitHub Pages configuration
  dynamic "pages" {
    for_each = var.pages != null ? [var.pages] : []
    content {
      source {
        branch = pages.value.source.branch
        path   = pages.value.source.path
      }
      cname      = pages.value.cname
      build_type = pages.value.build_type
    }
  }

  # Template repository
  dynamic "template" {
    for_each = var.template != null ? [var.template] : []
    content {
      owner                = template.value.owner
      repository           = template.value.repository
      include_all_branches = template.value.include_all_branches
    }
  }

  lifecycle {
    ignore_changes = [
      auto_init,
      gitignore_template,
      license_template,
    ]
  }
}

#----------------------------------------------------------------------------
# Team Permissions
#----------------------------------------------------------------------------

resource "github_team_repository" "teams" {
  for_each   = var.team_permissions
  team_id    = data.github_team.team_ids[each.key].id
  repository = github_repository.repository.name
  permission = each.value
}

#----------------------------------------------------------------------------
# Collaborator Permissions
#----------------------------------------------------------------------------

resource "github_repository_collaborator" "collaborators" {
  for_each   = var.collaborator_permissions
  repository = github_repository.repository.name
  username   = each.key
  permission = each.value
}

#----------------------------------------------------------------------------
# Branches
#----------------------------------------------------------------------------

resource "github_branch" "branches" {
  for_each      = toset([for k, v in var.branch_protection : k if k != var.default_branch])
  repository    = github_repository.repository.name
  branch        = each.key
  source_branch = var.default_branch

  depends_on = [github_repository.repository]
}

# Fix: Use separate resource for setting default branch
resource "github_branch_default" "default" {
  count      = var.default_branch != "main" ? 1 : 0
  repository = github_repository.repository.name
  branch     = var.default_branch

  depends_on = [github_repository.repository]
}

#----------------------------------------------------------------------------
# Branch Protection (Legacy) - FIXED
#----------------------------------------------------------------------------

resource "github_branch_protection" "protection" {
  for_each      = var.branch_protection
  repository_id = github_repository.repository.name
  pattern       = each.key

  required_linear_history         = lookup(each.value, "required_linear_history", null)
  require_conversation_resolution = lookup(each.value, "require_conversation_resolution", null)
  require_signed_commits          = lookup(each.value, "require_signed_commits", null)

  required_status_checks {
    strict   = lookup(each.value, "strict_status_checks", true)
    contexts = lookup(each.value, "status_check_contexts", [])
  }

  dynamic "required_pull_request_reviews" {
    for_each = lookup(each.value, "require_pull_request_reviews", false) ? [1] : []
    content {
      dismiss_stale_reviews           = lookup(each.value, "dismiss_stale_reviews", true)
      required_approving_review_count = lookup(each.value, "required_approving_review_count", 1)
      require_code_owner_reviews      = lookup(each.value, "require_code_owner_reviews", false)
      require_last_push_approval      = lookup(each.value, "require_last_push_approval", false)
      # REMOVED: restrict_review_dismissals - not supported
      # REMOVED: dismissal_restrictions - use dismissal_restrictions at top level
    }
  }

  # FIXED: Use correct attribute names
  enforce_admins      = lookup(each.value, "enforce_admins", false)
  allows_deletions    = lookup(each.value, "allows_deletions", false)
  allows_force_pushes = lookup(each.value, "allows_force_pushes", false)
  # REMOVED: push_restrictions - not supported in current provider version

  depends_on = [
    github_branch.branches,
    github_branch_default.default
  ]
}

#----------------------------------------------------------------------------
# Repository Rulesets (Modern replacement for branch protection)
#----------------------------------------------------------------------------

resource "github_repository_ruleset" "rulesets" {
  for_each    = var.repository_rulesets
  name        = each.key
  repository  = github_repository.repository.name
  target      = each.value.target
  enforcement = each.value.enforcement

  dynamic "conditions" {
    for_each = each.value.conditions != null ? [each.value.conditions] : []
    content {
      dynamic "ref_name" {
        for_each = conditions.value.ref_name != null ? [conditions.value.ref_name] : []
        content {
          include = ref_name.value.include
          exclude = ref_name.value.exclude
        }
      }
    }
  }

  dynamic "rules" {
    for_each = each.value.rules != null ? [each.value.rules] : []
    content {
      # Pull request rules
      dynamic "pull_request" {
        for_each = rules.value.pull_request != null ? [rules.value.pull_request] : []
        content {
          dismiss_stale_reviews_on_push     = pull_request.value.dismiss_stale_reviews_on_push
          require_code_owner_review         = pull_request.value.require_code_owner_review
          require_last_push_approval        = pull_request.value.require_last_push_approval
          required_approving_review_count   = pull_request.value.required_approving_review_count
          required_review_thread_resolution = pull_request.value.required_review_thread_resolution
        }
      }

      # Required status checks
      dynamic "required_status_checks" {
        for_each = rules.value.required_status_checks != null ? [rules.value.required_status_checks] : []
        content {
          dynamic "required_check" {
            for_each = required_status_checks.value.required_checks
            content {
              context        = required_check.value.context
              integration_id = required_check.value.integration_id
            }
          }
          strict_required_status_checks_policy = required_status_checks.value.strict_required_status_checks_policy
        }
      }

      # Commit rules
      dynamic "commit_message_pattern" {
        for_each = rules.value.commit_message_pattern != null ? [rules.value.commit_message_pattern] : []
        content {
          pattern  = commit_message_pattern.value.pattern
          name     = commit_message_pattern.value.name
          negate   = commit_message_pattern.value.negate
          operator = commit_message_pattern.value.operator
        }
      }

      dynamic "commit_author_email_pattern" {
        for_each = rules.value.commit_author_email_pattern != null ? [rules.value.commit_author_email_pattern] : []
        content {
          pattern  = commit_author_email_pattern.value.pattern
          name     = commit_author_email_pattern.value.name
          negate   = commit_author_email_pattern.value.negate
          operator = commit_author_email_pattern.value.operator
        }
      }

      # Branch rules
      creation                = lookup(rules.value, "creation", null)
      update                  = lookup(rules.value, "update", null)
      deletion                = lookup(rules.value, "deletion", null)
      required_linear_history = lookup(rules.value, "required_linear_history", null)
      required_signatures     = lookup(rules.value, "required_signatures", null)
      non_fast_forward        = lookup(rules.value, "non_fast_forward", null)
    }
  }

  depends_on = [
    github_branch.branches,
    github_branch_default.default
  ]
}

#----------------------------------------------------------------------------
# Repository Files
#----------------------------------------------------------------------------

resource "github_repository_file" "files" {
  for_each            = var.repository_files
  repository          = github_repository.repository.name
  file                = each.key
  content             = each.value.content
  branch              = lookup(each.value, "branch", var.default_branch)
  commit_message      = lookup(each.value, "commit_message", "Add ${each.key}")
  commit_author       = lookup(each.value, "commit_author", null)
  commit_email        = lookup(each.value, "commit_email", null)
  overwrite_on_create = lookup(each.value, "overwrite_on_create", false)

  depends_on = [
    github_repository.repository,
    github_branch.branches,
    github_branch_default.default
  ]
}

#----------------------------------------------------------------------------
# Deploy Keys
#----------------------------------------------------------------------------

resource "github_repository_deploy_key" "deploy_keys" {
  for_each   = var.deploy_keys
  title      = each.key
  repository = github_repository.repository.name
  key        = each.value.key
  read_only  = each.value.read_only
}

#----------------------------------------------------------------------------
# Webhooks
#----------------------------------------------------------------------------

resource "github_repository_webhook" "webhooks" {
  for_each   = var.webhooks
  repository = github_repository.repository.name

  configuration {
    url          = each.value.url
    content_type = each.value.content_type
    insecure_ssl = each.value.insecure_ssl
    secret       = each.value.secret
  }

  active = each.value.active
  events = each.value.events
}

#----------------------------------------------------------------------------
# Environments
#----------------------------------------------------------------------------

resource "github_repository_environment" "environments" {
  for_each    = var.environments
  repository  = github_repository.repository.name
  environment = each.key

  wait_timer          = each.value.wait_timer
  can_admins_bypass   = each.value.can_admins_bypass
  prevent_self_review = each.value.prevent_self_review

  dynamic "reviewers" {
    for_each = each.value.reviewers != null ? [each.value.reviewers] : []
    content {
      teams = reviewers.value.teams
      users = reviewers.value.users
    }
  }

  dynamic "deployment_branch_policy" {
    for_each = each.value.deployment_branch_policy != null ? [each.value.deployment_branch_policy] : []
    content {
      protected_branches     = deployment_branch_policy.value.protected_branches
      custom_branch_policies = deployment_branch_policy.value.custom_branch_policies
    }
  }
}

#----------------------------------------------------------------------------
# Environment Secrets
#----------------------------------------------------------------------------

resource "github_actions_environment_secret" "environment_secrets" {
  for_each = merge([
    for env_name, env_config in var.environments : {
      for secret_name, secret_value in lookup(env_config, "secrets", {}) :
      "${env_name}/${secret_name}" => {
        environment  = env_name
        secret_name  = secret_name
        secret_value = secret_value
      }
    }
  ]...)

  repository      = github_repository.repository.name
  environment     = each.value.environment
  secret_name     = each.value.secret_name
  plaintext_value = each.value.secret_value

  depends_on = [github_repository_environment.environments]
}

#----------------------------------------------------------------------------
# Environment Variables
#----------------------------------------------------------------------------

resource "github_actions_environment_variable" "environment_variables" {
  for_each = merge([
    for env_name, env_config in var.environments : {
      for var_name, var_value in lookup(env_config, "variables", {}) :
      "${env_name}/${var_name}" => {
        environment = env_name
        var_name    = var_name
        var_value   = var_value
      }
    }
  ]...)

  repository    = github_repository.repository.name
  environment   = each.value.environment
  variable_name = each.value.var_name
  value         = each.value.var_value

  depends_on = [github_repository_environment.environments]
}

#----------------------------------------------------------------------------
# Repository Secrets - FIXED for sensitive values
#----------------------------------------------------------------------------

resource "github_actions_secret" "repository_secrets" {
  for_each        = toset(local.repository_secret_keys)
  repository      = github_repository.repository.name
  secret_name     = each.key
  plaintext_value = var.repository_secrets[each.key]
}

#----------------------------------------------------------------------------
# Repository Variables
#----------------------------------------------------------------------------

resource "github_actions_variable" "repository_variables" {
  for_each      = var.repository_variables
  repository    = github_repository.repository.name
  variable_name = each.key
  value         = each.value
}
