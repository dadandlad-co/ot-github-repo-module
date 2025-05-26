#----------------------------------------------------------------------------
# Advanced Example - Repository with Branch Protection and Teams
#----------------------------------------------------------------------------

# Data sources for teams (replace with your actual team slugs)
data "github_team" "developers" {
  slug = "developers"
}

data "github_team" "maintainers" {
  slug = "maintainers"
}

module "advanced_repository" {
  source = "../.."

  # Repository settings
  name        = "advanced-example-repo"
  description = "Advanced example with branch protection and team access"
  visibility  = "private"
  
  homepage_url = "https://docs.example.com/advanced-repo"

  # Repository features
  has_issues   = true
  has_projects = true
  has_wiki     = true

  # Topics
  topics = ["api", "microservice", "production"]

  # Merge settings
  allow_merge_commit = false
  allow_squash_merge = true
  allow_rebase_merge = true
  allow_auto_merge   = true

  delete_branch_on_merge      = true
  squash_merge_commit_title   = "PR_TITLE"
  squash_merge_commit_message = "COMMIT_MESSAGES"

  # Security settings
  vulnerability_alerts = true
  
  security_and_analysis = {
    secret_scanning = {
      status = "enabled"
    }
    secret_scanning_push_protection = {
      status = "enabled"
    }
  }

  # Team permissions
  team_permissions = {
    "developers"  = "push"
    "maintainers" = "admin"
  }

  # Branch protection using modern rulesets
  repository_rulesets = {
    "main-protection" = {
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
          require_last_push_approval        = false
          required_review_thread_resolution = true
        }
        
        required_status_checks = {
          required_checks = [
            {
              context = "ci/tests"
            },
            {
              context = "ci/lint"
            }
          ]
          strict_required_status_checks_policy = true
        }
        
        commit_message_pattern = {
          pattern  = "^(feat|fix|docs|style|refactor|test|chore)(\\(.+\\))?: .+"
          operator = "regex"
          name     = "Conventional Commits"
        }
        
        required_signatures     = false
        required_linear_history = true
        deletion                = true
        non_fast_forward        = true
      }
    }
    
    "release-protection" = {
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
            {
              context = "ci/tests"
            }
          ]
          strict_required_status_checks_policy = true
        }
        
        deletion = true
      }
    }
  }

  # Repository files
  repository_files = {
    ".github/CODEOWNERS" = {
      content = <<-EOF
        # Global code owners
        * @dadandlad-co/maintainers
        
        # CI/CD files
        .github/ @dadandlad-co/platform-team
        
        # Documentation
        docs/ @dadandlad-co/technical-writers @dadandlad-co/maintainers
        *.md @dadandlad-co/technical-writers
      EOF
      
      commit_message = "Add CODEOWNERS file"
    }
    
    ".github/pull_request_template.md" = {
      content = <<-EOF
        ## Description
        Brief description of the changes in this PR.
        
        ## Type of Change
        - [ ] Bug fix
        - [ ] New feature
        - [ ] Breaking change
        - [ ] Documentation update
        
        ## Testing
        - [ ] Tests pass locally
        - [ ] Added new tests for new functionality
        
        ## Checklist
        - [ ] Code follows the project's style guidelines
        - [ ] Self-review completed
        - [ ] Documentation updated if necessary
        - [ ] No new warnings introduced
      EOF
      
      commit_message = "Add pull request template"
    }
  }

  # Environment for deployment
  environments = {
    "staging" = {
      wait_timer          = 0
      can_admins_bypass   = true
      prevent_self_review = false
      
      deployment_branch_policy = {
        protected_branches = true
      }
      
      variables = {
        "ENVIRONMENT" = "staging"
        "LOG_LEVEL"   = "debug"
      }
    }
    
    "production" = {
      wait_timer          = 30
      can_admins_bypass   = false
      prevent_self_review = true
      
      reviewers = {
        teams = [data.github_team.maintainers.id]
      }
      
      deployment_branch_policy = {
        protected_branches = true
      }
      
      variables = {
        "ENVIRONMENT" = "production"
        "LOG_LEVEL"   = "info"
      }
    }
  }

  # Repository-level variables
  repository_variables = {
    "PROJECT_NAME"   = "advanced-example"
    "DEFAULT_BRANCH" = "main"
  }
}

#----------------------------------------------------------------------------
# Outputs
#----------------------------------------------------------------------------

output "repository_url" {
  description = "The URL of the created repository"
  value       = module.advanced_repository.html_url
}

output "repository_clone_url" {
  description = "The SSH clone URL"
  value       = module.advanced_repository.ssh_clone_url
}

output "repository_name" {
  description = "The name of the repository"
  value       = module.advanced_repository.repository_name
}

output "branch_protection_rules" {
  description = "Branch protection rules configured"
  value       = module.advanced_repository.repository_rulesets
}

output "team_permissions" {
  description = "Team permissions configured"
  value       = module.advanced_repository.team_permissions
}

output "environments" {
  description = "Environments configured"
  value       = module.advanced_repository.environments
}