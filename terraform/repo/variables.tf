#----------------------------------------------------------------------------
# variables.tf - OpenTofu GitHub Repository Module
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# Repository Basic Settings
#----------------------------------------------------------------------------

variable "name" {
  description = "The name of the repository."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9._-]{1,100}$", var.name))
    error_message = "The repository name must be between 1 and 100 characters and can only contain alphanumeric characters, periods, underscores, or hyphens."
  }
}

variable "description" {
  description = "A description of the repository."
  type        = string
  default     = null
  validation {
    condition     = var.description == null || length(var.description) <= 1000
    error_message = "The repository description must be 1000 characters or less."
  }
}

variable "visibility" {
  description = "The visibility of the repository. Can be 'public', 'private', or 'internal'."
  type        = string
  default     = "private"
  validation {
    condition     = contains(["public", "private", "internal"], var.visibility)
    error_message = "Repository visibility must be 'public', 'private', or 'internal'."
  }
}

variable "homepage_url" {
  description = "URL of the repository's homepage."
  type        = string
  default     = null
  validation {
    condition = var.homepage_url == null || can(regex("^https?://[\\w.-]+(?:\\.[\\w\\.-]+)+[\\w\\-\\._~:/?#[\\]@!\\$&'\\(\\)\\*\\+,;=.]*$", var.homepage_url))
    error_message = "Invalid homepage URL format. Must be a valid HTTP or HTTPS URL."
  }
}

variable "archived" {
  description = "Set to true to archive the repository."
  type        = bool
  default     = false
}

variable "archive_on_destroy" {
  description = "Set to true to archive the repository instead of deleting on destroy."
  type        = bool
  default     = false
}

#----------------------------------------------------------------------------
# Repository Features
#----------------------------------------------------------------------------

variable "has_issues" {
  description = "Set to true to enable the GitHub Issues features on the repository."
  type        = bool
  default     = true
}

variable "has_projects" {
  description = "Set to true to enable the GitHub Projects features on the repository."
  type        = bool
  default     = true
}

variable "has_wiki" {
  description = "Set to true to enable the GitHub Wiki features on the repository."
  type        = bool
  default     = true
}

variable "vulnerability_alerts" {
  description = "Set to true to enable security alerts for the repository."
  type        = bool
  default     = true
}

#----------------------------------------------------------------------------
# Repository Initialization
#----------------------------------------------------------------------------

variable "auto_init" {
  description = "Set to true to automatically create an initial commit with an empty README file."
  type        = bool
  default     = false
}

variable "gitignore_template" {
  description = "Use a template for a .gitignore file."
  type        = string
  default     = null
}

variable "license_template" {
  description = "Use a template for a LICENSE file."
  type        = string
  default     = null
}

variable "template" {
  description = "Use a template repository to create this repository."
  type = object({
    owner                = string
    repository           = string
    include_all_branches = optional(bool, false)
  })
  default = null
}

#----------------------------------------------------------------------------
# Merge Settings
#----------------------------------------------------------------------------

variable "allow_merge_commit" {
  description = "Set to true to allow merge commits for pull requests."
  type        = bool
  default     = true
}

variable "allow_squash_merge" {
  description = "Set to true to allow squash merges for pull requests."
  type        = bool
  default     = true
}

variable "allow_rebase_merge" {
  description = "Set to true to allow rebase merges for pull requests."
  type        = bool
  default     = true
}

variable "allow_auto_merge" {
  description = "Set to true to allow auto-merging pull requests."
  type        = bool
  default     = false
}

variable "delete_branch_on_merge" {
  description = "Set to true to delete the base branch after pull request merge."
  type        = bool
  default     = false
}

variable "allow_update_branch" {
  description = "Set to true to allow updating pull request branches."
  type        = bool
  default     = false
}

variable "squash_merge_commit_title" {
  description = "The default value for a squash merge commit title."
  type        = string
  default     = "COMMIT_OR_PR_TITLE"
  validation {
    condition     = contains(["PR_TITLE", "COMMIT_OR_PR_TITLE"], var.squash_merge_commit_title)
    error_message = "Must be one of 'PR_TITLE' or 'COMMIT_OR_PR_TITLE'."
  }
}

variable "squash_merge_commit_message" {
  description = "The default value for a squash merge commit message."
  type        = string
  default     = "COMMIT_MESSAGES"
  validation {
    condition     = contains(["PR_BODY", "COMMIT_MESSAGES", "BLANK"], var.squash_merge_commit_message)
    error_message = "Must be one of 'PR_BODY', 'COMMIT_MESSAGES', or 'BLANK'."
  }
}

variable "merge_commit_title" {
  description = "The default value for a merge commit title."
  type        = string
  default     = "MERGE_MESSAGE"
  validation {
    condition     = contains(["PR_TITLE", "MERGE_MESSAGE"], var.merge_commit_title)
    error_message = "Must be one of 'PR_TITLE' or 'MERGE_MESSAGE'."
  }
}

variable "merge_commit_message" {
  description = "The default value for a merge commit message."
  type        = string
  default     = "PR_TITLE"
  validation {
    condition     = contains(["PR_BODY", "PR_TITLE", "BLANK"], var.merge_commit_message)
    error_message = "Must be one of 'PR_BODY', 'PR_TITLE', or 'BLANK'."
  }
}

variable "web_commit_signoff_required" {
  description = "Require contributors to sign off on web-based commits."
  type        = bool
  default     = false
}

#----------------------------------------------------------------------------
# Branch Settings
#----------------------------------------------------------------------------

variable "default_branch" {
  description = "The name of the default branch of the repository."
  type        = string
  default     = "main"
  validation {
    condition     = can(regex("^[a-zA-Z0-9/_.-]{1,250}$", var.default_branch))
    error_message = "Branch name must be between 1 and 250 characters and can only contain alphanumeric characters, slashes, underscores, periods, or hyphens."
  }
}

#----------------------------------------------------------------------------
# Branch Protection (Legacy)
#----------------------------------------------------------------------------

variable "branch_protection" {
  description = "Configure branch protection rules (legacy). Consider using repository_rulesets instead."
  type = map(object({
    required_status_checks = optional(object({
      strict   = optional(bool, true)
      contexts = optional(list(string), [])
    }))
    enforce_admins                  = optional(bool, false)
    require_pull_request_reviews    = optional(bool, false)
    required_approving_review_count = optional(number, 1)
    dismiss_stale_reviews           = optional(bool, true)
    require_code_owner_reviews      = optional(bool, false)
    require_last_push_approval      = optional(bool, false)
    restrict_review_dismissals      = optional(bool, false)
    dismissal_restrictions          = optional(list(string), [])
    required_linear_history         = optional(bool, false)
    require_conversation_resolution = optional(bool, false)
    require_signed_commits          = optional(bool, false)
    allows_deletions                = optional(bool, false)
    allows_force_pushes             = optional(bool, false)
    push_restrictions               = optional(list(string), [])
    status_check_contexts           = optional(list(string), [])
    strict_status_checks            = optional(bool, true)
  }))
  default = {}
}

#----------------------------------------------------------------------------
# Repository Rulesets (Modern)
#----------------------------------------------------------------------------

variable "repository_rulesets" {
  description = "Configure repository rulesets (modern replacement for branch protection)."
  type = map(object({
    target      = string # "branch" or "tag"
    enforcement = string # "active", "evaluate", or "disabled"
    conditions = optional(object({
      ref_name = optional(object({
        include = list(string)
        exclude = optional(list(string), [])
      }))
    }))
    rules = optional(object({
      # Pull request rules
      pull_request = optional(object({
        dismiss_stale_reviews_on_push     = optional(bool, false)
        require_code_owner_review         = optional(bool, false)
        require_last_push_approval        = optional(bool, false)
        required_approving_review_count   = optional(number, 1)
        required_review_thread_resolution = optional(bool, false)
      }))
      # Status check rules
      required_status_checks = optional(object({
        required_checks = list(object({
          context        = string
          integration_id = optional(number)
        }))
        strict_required_status_checks_policy = optional(bool, false)
      }))
      # Commit rules
      commit_message_pattern = optional(object({
        pattern  = string
        name     = optional(string)
        negate   = optional(bool, false)
        operator = string # "starts_with", "ends_with", "contains", "regex"
      }))
      commit_author_email_pattern = optional(object({
        pattern  = string
        name     = optional(string)
        negate   = optional(bool, false)
        operator = string # "starts_with", "ends_with", "contains", "regex"
      }))
      # Branch rules
      creation                = optional(bool)
      update                  = optional(bool)
      deletion                = optional(bool)
      required_linear_history = optional(bool)
      required_signatures     = optional(bool)
      non_fast_forward        = optional(bool)
    }))
  }))
  default = {}
}

#----------------------------------------------------------------------------
# Topics and Labels
#----------------------------------------------------------------------------

variable "topics" {
  description = "A list of topics to apply to the repository."
  type        = list(string)
  default     = []
  validation {
    condition = length(var.topics) <= 20 && alltrue([
      for t in var.topics : can(regex("^[a-z0-9-]{1,50}$", t))
    ])
    error_message = "A maximum of 20 topics are allowed for a repository, each between 1 and 50 characters and can only contain lowercase alphanumeric characters or hyphens."
  }
}

variable "default_topics" {
  description = "Default topics to always apply to repositories."
  type        = list(string)
  default     = ["opentofu", "terraform", "infrastructure"]
  validation {
    condition = length(var.default_topics) <= 10 && alltrue([
      for t in var.default_topics : can(regex("^[a-z0-9-]{1,50}$", t))
    ])
    error_message = "A maximum of 10 default topics are allowed, each between 1 and 50 characters and can only contain lowercase alphanumeric characters or hyphens."
  }
}

#----------------------------------------------------------------------------
# Team and Collaborator Permissions
#----------------------------------------------------------------------------

variable "team_permissions" {
  description = "The team permissions settings for the repository. Each team is mapped to a permission (admin, maintain, pull, push, triage)."
  type        = map(string)
  default     = {}
  validation {
    condition = alltrue([
      for v in values(var.team_permissions) : contains(["admin", "maintain", "pull", "push", "triage"], v)
    ])
    error_message = "Invalid team permission. Allowed values are: admin, maintain, pull, push, triage."
  }
  validation {
    condition     = length(var.team_permissions) <= 100
    error_message = "A maximum of 100 team permissions are allowed for a repository."
  }
}

variable "collaborator_permissions" {
  description = "The collaborator permissions settings for the repository. Each user is mapped to a permission (admin, maintain, pull, push, triage)."
  type        = map(string)
  default     = {}
  validation {
    condition = alltrue([
      for v in values(var.collaborator_permissions) : contains(["admin", "maintain", "pull", "push", "triage"], v)
    ])
    error_message = "Invalid collaborator permission. Allowed values are: admin, maintain, pull, push, triage."
  }
  validation {
    condition     = length(var.collaborator_permissions) <= 100
    error_message = "A maximum of 100 collaborator permissions are allowed for a repository."
  }
}

#----------------------------------------------------------------------------
# Repository Files
#----------------------------------------------------------------------------

variable "repository_files" {
  description = "Add files to the repository (CODEOWNERS, .gitignore, etc.)."
  type = map(object({
    content             = string
    branch              = optional(string)
    commit_message      = optional(string)
    commit_author       = optional(string)
    commit_email        = optional(string)
    overwrite_on_create = optional(bool, false)
  }))
  default = {}
  validation {
    condition     = length(var.repository_files) <= 100
    error_message = "A maximum of 100 files can be added to the repository."
  }
  validation {
    condition = alltrue([
      for k, v in var.repository_files : length(k) <= 256 && length(v.content) <= 1048576
    ])
    error_message = "File names must not exceed 256 characters, and file content must not exceed 1MB (1,048,576 bytes)."
  }
}

#----------------------------------------------------------------------------
# GitHub Pages
#----------------------------------------------------------------------------

variable "pages" {
  description = "The GitHub Pages configuration for the repository."
  type = object({
    source = object({
      branch = string
      path   = optional(string, "/")
    })
    build_type = optional(string, "workflow") # "legacy" or "workflow"
    cname      = optional(string)
  })
  default = null
}

#----------------------------------------------------------------------------
# Security and Analysis
#----------------------------------------------------------------------------

variable "security_and_analysis" {
  description = "Security and analysis settings for the repository."
  type = object({
    advanced_security = optional(object({
      status = string # "enabled" or "disabled"
    }))
    secret_scanning = optional(object({
      status = string # "enabled" or "disabled"
    }))
    secret_scanning_push_protection = optional(object({
      status = string # "enabled" or "disabled"
    }))
  })
  default = null
}

#----------------------------------------------------------------------------
# Deploy Keys
#----------------------------------------------------------------------------

variable "deploy_keys" {
  description = "Deploy keys for the repository."
  type = map(object({
    key       = string
    read_only = optional(bool, true)
  }))
  default = {}
  validation {
    condition     = length(var.deploy_keys) <= 100
    error_message = "A maximum of 100 deploy keys are allowed for a repository."
  }
}

#----------------------------------------------------------------------------
# Webhooks
#----------------------------------------------------------------------------

variable "webhooks" {
  description = "Webhooks for the repository."
  type = map(object({
    url          = string
    content_type = optional(string, "json") # "json" or "form"
    insecure_ssl = optional(bool, false)
    secret       = optional(string)
    active       = optional(bool, true)
    events       = list(string)
  }))
  default = {}
  validation {
    condition     = length(var.webhooks) <= 20
    error_message = "A maximum of 20 webhooks are allowed for a repository."
  }
  validation {
    condition = alltrue([
      for k, v in var.webhooks : contains(["json", "form"], v.content_type)
    ])
    error_message = "Webhook content_type must be 'json' or 'form'."
  }
}

#----------------------------------------------------------------------------
# Environments
#----------------------------------------------------------------------------

variable "environments" {
  description = "Repository environments configuration."
  type = map(object({
    wait_timer          = optional(number, 0)
    can_admins_bypass   = optional(bool, true)
    prevent_self_review = optional(bool, false)
    reviewers = optional(object({
      teams = optional(list(number), [])
      users = optional(list(number), [])
    }))
    deployment_branch_policy = optional(object({
      protected_branches     = optional(bool, false)
      custom_branch_policies = optional(bool, false)
    }))
    secrets   = optional(map(string), {})
    variables = optional(map(string), {})
  }))
  default = {}
  validation {
    condition     = length(var.environments) <= 100
    error_message = "A maximum of 100 environments are allowed for a repository."
  }
}

#----------------------------------------------------------------------------
# Repository Secrets and Variables
#----------------------------------------------------------------------------

variable "repository_secrets" {
  description = "Repository-level secrets for GitHub Actions."
  type        = map(string)
  default     = {}
  sensitive   = true
  validation {
    condition     = length(var.repository_secrets) <= 100
    error_message = "A maximum of 100 repository secrets are allowed."
  }
}

variable "repository_variables" {
  description = "Repository-level variables for GitHub Actions."
  type        = map(string)
  default     = {}
  validation {
    condition     = length(var.repository_variables) <= 100
    error_message = "A maximum of 100 repository variables are allowed."
  }
}