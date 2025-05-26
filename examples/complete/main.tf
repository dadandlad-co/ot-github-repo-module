#----------------------------------------------------------------------------
# Complete Example - All Features Enabled (FIXED)
#----------------------------------------------------------------------------

# Variables for secrets (normally from environment or vault)
variable "production_database_url" {
  description = "Production database URL"
  type        = string
  sensitive   = true
  default     = "postgresql://prod:secret@db.example.com:5432/app"
}

variable "staging_database_url" {
  description = "Staging database URL"
  type        = string
  sensitive   = true
  default     = "postgresql://staging:secret@staging-db.example.com:5432/app"
}

variable "api_key" {
  description = "API key for external services"
  type        = string
  sensitive   = true
  default     = "fake-api-key-for-example"
}

variable "slack_webhook_url" {
  description = "Slack webhook URL for notifications"
  type        = string
  sensitive   = true
  default     = "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX"
}

variable "production_deploy_key" {
  description = "SSH public key for production deployments"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC... production-deploy-key"
}

variable "staging_deploy_key" {
  description = "SSH public key for staging deployments"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC... staging-deploy-key"
}

# Data sources for teams (replace with your actual team slugs)
data "github_team" "platform_team" {
  slug = "platform-team"
}

data "github_team" "developers" {
  slug = "developers"
}

data "github_team" "security_team" {
  slug = "security-team"
}

#----------------------------------------------------------------------------
# Complete Repository Module
#----------------------------------------------------------------------------

module "complete_repository" {
  source = "../.."

  # Basic repository settings
  name         = "complete-example-repo"
  description  = "Complete example showcasing all OpenTofu GitHub repository module features"
  visibility   = "private"
  homepage_url = "https://docs.example.com/complete-repo"

  # Repository features
  has_issues   = true
  has_projects = true
  has_wiki     = true

  # Topics for discoverability
  topics = [
    "api",
    "microservice",
    "production",
    "kubernetes",
    "golang"
  ]

  # Archive settings
  archived           = false
  archive_on_destroy = true

  # Merge settings - enforce clean git history
  allow_merge_commit = false
  allow_squash_merge = true
  allow_rebase_merge = true
  allow_auto_merge   = true

  delete_branch_on_merge      = true
  allow_update_branch         = true
  web_commit_signoff_required = true

  squash_merge_commit_title   = "PR_TITLE"
  squash_merge_commit_message = "COMMIT_MESSAGES"
  merge_commit_title          = "MERGE_MESSAGE"
  merge_commit_message        = "PR_TITLE"

  # Security settings
  vulnerability_alerts = true

  security_and_analysis = {
    secret_scanning = {
      status = "enabled"
    }
    secret_scanning_push_protection = {
      status = "enabled"
    }
    # Note: advanced_security requires GitHub Enterprise
    # advanced_security = {
    #   status = "enabled"
    # }
  }

  # Team and collaborator permissions
  team_permissions = {
    "developers"    = "push"
    "platform-team" = "admin"
    "security-team" = "maintain"
  }

  collaborator_permissions = {
    "external-consultant" = "pull"
    "security-auditor"    = "triage"
  }

  # Modern branch protection with repository rulesets
  repository_rulesets = {
    # Main branch protection
    "main-branch-protection" = {
      target      = "branch"
      enforcement = "active"

      conditions = {
        ref_name = {
          include = ["main", "master"]
        }
      }

      rules = {
        pull_request = {
          required_approving_review_count   = 2
          require_code_owner_review         = true
          dismiss_stale_reviews_on_push     = true
          require_last_push_approval        = true
          required_review_thread_resolution = true
        }

        required_status_checks = {
          required_checks = [
            { context = "ci/tests" },
            { context = "ci/security-scan" },
            { context = "ci/lint" },
            { context = "ci/build" }
          ]
          strict_required_status_checks_policy = true
        }

        # Enforce conventional commits
        commit_message_pattern = {
          pattern  = "^(feat|fix|docs|style|refactor|perf|test|chore)(\\(.+\\))?: .{1,72}"
          operator = "regex"
          name     = "Conventional Commits"
        }

        # Enforce company email domain
        commit_author_email_pattern = {
          pattern  = "@(dadandlad\\.co|example\\.com)$"
          operator = "regex"
          name     = "Company Email Required"
        }

        # Branch rules
        required_signatures     = false # Enable if you have signing set up
        required_linear_history = true
        deletion                = true
        non_fast_forward        = true
      }
    }

    # Release branch protection
    "release-branch-protection" = {
      target      = "branch"
      enforcement = "active"

      conditions = {
        ref_name = {
          include = ["release/*", "hotfix/*"]
        }
      }

      rules = {
        pull_request = {
          required_approving_review_count = 1
          require_code_owner_review       = true
        }

        required_status_checks = {
          required_checks = [
            { context = "ci/tests" },
            { context = "ci/security-scan" }
          ]
          strict_required_status_checks_policy = true
        }

        deletion = true
      }
    }

    # Tag protection
    "tag-protection" = {
      target      = "tag"
      enforcement = "active"

      conditions = {
        ref_name = {
          include = ["v*"]
        }
      }

      rules = {
        creation = true
        update   = false
        deletion = true
      }
    }
  }

  # Repository files
  repository_files = {
    # Code ownership
    ".github/CODEOWNERS" = {
      content        = <<-EOF
        # Global code owners
        * @dadandlad-co/platform-team

        # API and core application code
        /api/ @dadandlad-co/developers @dadandlad-co/platform-team
        /pkg/ @dadandlad-co/developers

        # Infrastructure and deployment
        /deploy/ @dadandlad-co/platform-team
        /k8s/ @dadandlad-co/platform-team
        /.github/ @dadandlad-co/platform-team

        # Security-sensitive files
        /security/ @dadandlad-co/security-team @dadandlad-co/platform-team
        *.yaml @dadandlad-co/platform-team
        *.yml @dadandlad-co/platform-team
        Dockerfile* @dadandlad-co/platform-team

        # Documentation
        /docs/ @dadandlad-co/technical-writers @dadandlad-co/developers
        *.md @dadandlad-co/technical-writers
        README.md @dadandlad-co/platform-team @dadandlad-co/technical-writers
      EOF
      commit_message = "Add comprehensive CODEOWNERS file"
    }

    # Pull request template
    ".github/pull_request_template.md" = {
      content        = <<-EOF
        ## 📋 Description

        Brief description of the changes in this pull request.

        Fixes #(issue number)

        ## 🔄 Type of Change

        - [ ] 🐛 Bug fix (non-breaking change which fixes an issue)
        - [ ] ✨ New feature (non-breaking change which adds functionality)
        - [ ] 💥 Breaking change (fix or feature that would cause existing functionality to not work as expected)
        - [ ] 📚 Documentation update
        - [ ] 🎨 Code style update (formatting, renaming)
        - [ ] ♻️ Code refactoring (no functional changes, no api changes)
        - [ ] ⚡ Performance improvements
        - [ ] ✅ Test updates
        - [ ] 🔧 Build configuration changes
        - [ ] 🚀 CI/CD changes

        ## 🧪 Testing

        - [ ] Tests pass locally with my changes
        - [ ] I have added tests that prove my fix is effective or that my feature works
        - [ ] New and existing unit tests pass locally with my changes
        - [ ] I have performed a self-review of my own code

        ## 📸 Screenshots (if applicable)

        Add screenshots or recordings to help explain your changes.

        ## 📝 Additional Notes

        Add any other context about the pull request here.

        ## ✅ Checklist

        - [ ] My code follows the project's style guidelines
        - [ ] I have commented my code, particularly in hard-to-understand areas
        - [ ] I have made corresponding changes to the documentation
        - [ ] My changes generate no new warnings
        - [ ] Any dependent changes have been merged and published
      EOF
      commit_message = "Add detailed pull request template"
    }

    # Issue templates
    ".github/ISSUE_TEMPLATE/bug_report.yml" = {
      content        = <<-EOF
        name: 🐛 Bug Report
        description: File a bug report to help us improve
        title: "[Bug]: "
        labels: ["bug", "needs-triage"]
        body:
          - type: markdown
            attributes:
              value: |
                Thanks for taking the time to fill out this bug report! 🙏

          - type: textarea
            id: what-happened
            attributes:
              label: What happened?
              description: A clear and concise description of what the bug is.
              placeholder: Tell us what you see!
            validations:
              required: true

          - type: textarea
            id: expected
            attributes:
              label: Expected Behavior
              description: A clear and concise description of what you expected to happen.
            validations:
              required: true

          - type: textarea
            id: reproduce
            attributes:
              label: Steps to Reproduce
              description: Steps to reproduce the behavior
              placeholder: |
                1. Go to '...'
                2. Click on '....'
                3. Scroll down to '....'
                4. See error
            validations:
              required: true

          - type: textarea
            id: environment
            attributes:
              label: Environment
              description: |
                Please provide information about your environment:
              value: |
                - OS: [e.g. Ubuntu 20.04, macOS 12.0]
                - Browser: [e.g. Chrome 96, Safari 15]
                - Version: [e.g. 1.2.3]
            validations:
              required: true
      EOF
      commit_message = "Add bug report issue template"
    }

    # Contributing guidelines
    "CONTRIBUTING.md" = {
      content        = <<-EOF
        # Contributing to Complete Example Repository

        We love your input! We want to make contributing to this project as easy and transparent as possible.

        ## Development Process

        We use GitHub to host code, to track issues and feature requests, as well as accept pull requests.

        1. Fork the repo and create your branch from `main`.
        2. If you've added code that should be tested, add tests.
        3. If you've changed APIs, update the documentation.
        4. Ensure the test suite passes.
        5. Make sure your code lints.
        6. Issue that pull request!

        ## Pull Request Process

        1. Update the README.md with details of changes to the interface, if applicable.
        2. Increase the version numbers in any examples files and the README.md to the new version that this Pull Request would represent.
        3. You may merge the Pull Request in once you have the sign-off of two other developers, or if you do not have permission to do that, you may request the second reviewer to merge it for you.

        ## Code Style

        * Use conventional commits: `feat:`, `fix:`, `docs:`, etc.
        * Follow the existing code style
        * Add tests for new functionality
        * Update documentation as needed

        ## License

        By contributing, you agree that your contributions will be licensed under the same license as the project.
      EOF
      commit_message = "Add contributing guidelines"
    }

    # Security policy
    "SECURITY.md" = {
      content        = <<-EOF
        # Security Policy

        ## Supported Versions

        We currently support the following versions with security updates:

        | Version | Supported          |
        | ------- | ------------------ |
        | 1.x.x   | :white_check_mark: |
        | < 1.0   | :x:                |

        ## Reporting a Vulnerability

        Please do not report security vulnerabilities through public GitHub issues.

        Instead, please report them via email to security@example.com or through GitHub's private vulnerability reporting feature.

        You should receive a response within 48 hours. If for some reason you do not, please follow up via email to ensure we received your original message.

        Please include the requested information listed below (as much as you can provide) to help us better understand the nature and scope of the possible issue:

        * Type of issue (e.g. buffer overflow, SQL injection, cross-site scripting, etc.)
        * Full paths of source file(s) related to the manifestation of the issue
        * The location of the affected source code (tag/branch/commit or direct URL)
        * Any special configuration required to reproduce the issue
        * Step-by-step instructions to reproduce the issue
        * Proof-of-concept or exploit code (if possible)
        * Impact of the issue, including how an attacker might exploit the issue

        This information will help us triage your report more quickly.
      EOF
      commit_message = "Add security policy"
    }
  }

  # Deploy keys for automated deployments
  deploy_keys = {
    "production-deploy" = {
      key       = var.production_deploy_key
      read_only = false
    }
    "staging-deploy" = {
      key       = var.staging_deploy_key
      read_only = false
    }
    "monitoring-readonly" = {
      key       = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC... monitoring-key"
      read_only = true
    }
  }

  # Webhooks for external integrations
  webhooks = {
    "ci-system" = {
      url          = "https://ci.example.com/hooks/github"
      content_type = "json"
      events = [
        "push",
        "pull_request",
        "pull_request_review",
        "release",
        "deployment",
        "deployment_status"
      ]
      active = true
    }

    "slack-notifications" = {
      url          = var.slack_webhook_url
      content_type = "json"
      events = [
        "issues",
        "issue_comment",
        "pull_request",
        "pull_request_review",
        "push",
        "release"
      ]
      active = true
      secret = "webhook-secret-for-slack"
    }

    "security-scanner" = {
      url          = "https://security.example.com/webhook"
      content_type = "json"
      events       = ["push", "pull_request", "release"]
      active       = true
    }
  }

  # GitHub Pages for documentation
  pages = {
    source = {
      branch = "gh-pages"
      path   = "/"
    }
    build_type = "workflow"
    cname      = "docs.complete-example.com"
  }

  # Multiple environments with different protection levels
  environments = {
    # Development environment - minimal protection
    "development" = {
      wait_timer          = 0
      can_admins_bypass   = true
      prevent_self_review = false

      variables = {
        "ENVIRONMENT"   = "development"
        "LOG_LEVEL"     = "debug"
        "API_BASE_URL"  = "https://api-dev.example.com"
        "FEATURE_FLAGS" = "all-enabled"
      }

      secrets = {
        "DATABASE_URL" = var.staging_database_url
        "API_KEY"      = var.api_key
        "JWT_SECRET"   = "dev-jwt-secret-key"
      }
    }

    # Staging environment - moderate protection
    "staging" = {
      wait_timer          = 5
      can_admins_bypass   = true
      prevent_self_review = false

      deployment_branch_policy = {
        protected_branches     = true
        custom_branch_policies = false
      }

      reviewers = {
        teams = [data.github_team.developers.id]
      }

      variables = {
        "ENVIRONMENT"   = "staging"
        "LOG_LEVEL"     = "info"
        "API_BASE_URL"  = "https://api-staging.example.com"
        "FEATURE_FLAGS" = "beta-enabled"
      }

      secrets = {
        "DATABASE_URL" = var.staging_database_url
        "API_KEY"      = var.api_key
        "JWT_SECRET"   = "staging-jwt-secret-key"
      }
    }

    # Production environment - maximum protection
    "production" = {
      wait_timer          = 30
      can_admins_bypass   = false
      prevent_self_review = true

      deployment_branch_policy = {
        protected_branches     = true
        custom_branch_policies = false
      }

      reviewers = {
        teams = [data.github_team.platform_team.id, data.github_team.security_team.id]
      }

      variables = {
        "ENVIRONMENT"    = "production"
        "LOG_LEVEL"      = "warn"
        "API_BASE_URL"   = "https://api.example.com"
        "FEATURE_FLAGS"  = "stable-only"
        "MONITORING_URL" = "https://monitoring.example.com"
      }

      secrets = {
        "DATABASE_URL"        = var.production_database_url
        "API_KEY"             = var.api_key
        "JWT_SECRET"          = "production-jwt-secret-key"
        "ENCRYPTION_KEY"      = "production-encryption-key"
        "THIRD_PARTY_API_KEY" = "production-third-party-key"
      }
    }

    # Demo environment for client demonstrations
    "demo" = {
      wait_timer          = 0
      can_admins_bypass   = true
      prevent_self_review = false

      variables = {
        "ENVIRONMENT"  = "demo"
        "LOG_LEVEL"    = "info"
        "API_BASE_URL" = "https://api-demo.example.com"
        "DEMO_DATA"    = "enabled"
      }

      secrets = {
        "DATABASE_URL" = "postgresql://demo:demo@demo-db.example.com:5432/demo"
        "API_KEY"      = "demo-api-key"
      }
    }
  }

  # Repository-level secrets and variables
  repository_secrets = {
    "SHARED_API_KEY"        = var.api_key
    "DOCKER_REGISTRY_TOKEN" = "registry-access-token"
    "NPM_TOKEN"             = "npm-registry-token"
    "CODECOV_TOKEN"         = "codecov-upload-token"
  }

  repository_variables = {
    "PROJECT_NAME"            = "complete-example"
    "DEFAULT_BRANCH"          = "main"
    "DOCKER_REGISTRY"         = "ghcr.io/dadandlad-co"
    "SUPPORTED_NODE_VERSIONS" = "18,20,22"
    "MINIMUM_COVERAGE"        = "80"
    "BUILD_TIMEOUT"           = "30m"
  }
}

#----------------------------------------------------------------------------
# Outputs
#----------------------------------------------------------------------------

output "repository_url" {
  description = "The URL of the created repository"
  value       = module.complete_repository.html_url
}

output "repository_clone_url" {
  description = "The SSH clone URL"
  value       = module.complete_repository.ssh_clone_url
}

output "repository_name" {
  description = "The name of the repository"
  value       = module.complete_repository.repository_name
}

output "repository_full_name" {
  description = "The full name (owner/name) of the repository"
  value       = module.complete_repository.repository_full_name
}

output "default_branch" {
  description = "The default branch of the repository"
  value       = module.complete_repository.repository_default_branch
}

output "repository_rulesets" {
  description = "Information about repository rulesets"
  value       = module.complete_repository.repository_rulesets
}

output "team_permissions" {
  description = "Team permissions configured for the repository"
  value       = module.complete_repository.team_permissions
}

output "collaborator_permissions" {
  description = "Collaborator permissions configured for the repository"
  value       = module.complete_repository.collaborator_permissions
}

output "environments" {
  description = "Environments configured for the repository"
  value       = module.complete_repository.environments
}

output "deploy_keys" {
  description = "Deploy keys configured for the repository"
  value       = module.complete_repository.deploy_keys
  sensitive   = true
}

output "webhooks" {
  description = "Webhooks configured for the repository"
  value       = module.complete_repository.webhooks
  sensitive   = true
}

output "pages_url" {
  description = "The URL of the repository's GitHub Pages site"
  value       = module.complete_repository.pages_url
}

output "security_settings" {
  description = "Security and analysis settings"
  value       = module.complete_repository.security_and_analysis
}

output "repository_files" {
  description = "Files added to the repository"
  value       = keys(module.complete_repository.repository_files)
}
