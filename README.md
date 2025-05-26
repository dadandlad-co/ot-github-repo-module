# OpenTofu GitHub Repository Module

A comprehensive OpenTofu module for managing GitHub repositories with all the features you need for modern DevOps workflows.

## Features

This module provides complete GitHub repository management including:

### Core Repository Management
- Repository creation with templates
- Visibility control (public, private, internal)
- Repository settings (issues, projects, wiki, etc.)
- Topics and descriptions
- Homepage URLs and archiving

### Branch Management
- Custom default branch configuration
- Additional branch creation
- Legacy branch protection rules
- Modern repository rulesets (recommended)

### Access Control
- Team permissions management
- Individual collaborator permissions
- Deploy key management

### GitHub Actions Integration
- Repository-level secrets and variables
- Environment-specific secrets and variables
- Environment protection rules and reviewers

### Advanced Features
- Repository file management (CODEOWNERS, etc.)
- GitHub Pages configuration
- Webhook management
- Security and analysis settings
- Merge strategy configuration

## Usage

### Basic Repository

```hcl
module "basic_repo" {
  source = "github.com/dadandlad-co/tf-github-github-repository"

  name        = "my-awesome-project"
  description = "An awesome project built with OpenTofu"
  visibility  = "private"
  
  topics = ["api", "microservice"]
  
  has_issues   = true
  has_projects = true
  has_wiki     = false
}
```

### Repository with Branch Protection

```hcl
module "protected_repo" {
  source = "github.com/dadandlad-co/tf-github-github-repository"

  name        = "production-api"
  description = "Production API with strict branch protection"
  visibility  = "private"

  default_branch = "main"

  # Modern approach using repository rulesets (recommended)
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
          required_approving_review_count = 2
          require_code_owner_review       = true
          require_last_push_approval      = true
        }
        
        required_status_checks = {
          required_checks = [
            {
              context = "ci/tests"
            },
            {
              context = "ci/security-scan"
            }
          ]
          strict_required_status_checks_policy = true
        }
        
        required_signatures = true
        deletion = true
      }
    }
  }

  team_permissions = {
    "developers" = "push"
    "admins"     = "admin"
  }
}
```

### Repository with Environments and Secrets

```hcl
module "deployment_repo" {
  source = "github.com/dadandlad-co/tf-github-github-repository"

  name        = "web-application"
  description = "Web application with deployment environments"
  visibility  = "private"

  environments = {
    "development" = {
      wait_timer          = 0
      can_admins_bypass   = true
      prevent_self_review = false
      
      secrets = {
        "DATABASE_URL" = "postgresql://dev-db:5432/myapp"
        "API_KEY"      = var.dev_api_key
      }
      
      variables = {
        "ENVIRONMENT" = "development"
        "LOG_LEVEL"   = "debug"
      }
    }
    
    "production" = {
      wait_timer          = 30
      can_admins_bypass   = false
      prevent_self_review = true
      
      reviewers = {
        teams = [data.github_team.platform_team.id]
      }
      
      deployment_branch_policy = {
        protected_branches = true
      }
      
      secrets = {
        "DATABASE_URL" = var.prod_database_url
        "API_KEY"      = var.prod_api_key
      }
      
      variables = {
        "ENVIRONMENT" = "production"
        "LOG_LEVEL"   = "info"
      }
    }
  }

  repository_secrets = {
    "SHARED_SECRET" = var.shared_secret
  }

  repository_variables = {
    "PROJECT_NAME" = "web-application"
  }
}
```

### Repository from Template

```hcl
module "templated_repo" {
  source = "github.com/dadandlad-co/tf-github-github-repository"

  name        = "new-microservice"
  description = "New microservice created from template"
  visibility  = "private"

  template = {
    owner                = "dadandlad-co"
    repository           = "microservice-template"
    include_all_branches = false
  }

  repository_files = {
    ".github/CODEOWNERS" = {
      content = <<-EOF
        # Global owners
        * @dadandlad-co/platform-team
        
        # API specific
        /api/ @dadandlad-co/api-team
        
        # Infrastructure
        /terraform/ @dadandlad-co/platform-team
        /.github/ @dadandlad-co/platform-team
      EOF
      
      commit_message = "Add CODEOWNERS file"
    }
  }

  webhooks = {
    "ci-webhook" = {
      url          = "https://ci.example.com/webhook"
      content_type = "json"
      events       = ["push", "pull_request"]
      active       = true
    }
  }
}
```

### Complete Example with All Features

```hcl
module "complete_repo" {
  source = "github.com/dadandlad-co/tf-github-github-repository"

  # Basic settings
  name         = "complete-example"
  description  = "Complete example showcasing all module features"
  visibility   = "private"
  homepage_url = "https://example.com"

  # Repository features
  has_issues   = true
  has_projects = true
  has_wiki     = false

  # Topics
  topics = ["example", "complete", "showcase"]

  # Merge settings
  allow_merge_commit = true
  allow_squash_merge = true
  allow_rebase_merge = false
  allow_auto_merge   = true
  
  delete_branch_on_merge = true
  
  squash_merge_commit_title   = "PR_TITLE"
  squash_merge_commit_message = "COMMIT_MESSAGES"

  # Security
  vulnerability_alerts = true
  
  security_and_analysis = {
    secret_scanning = {
      status = "enabled"
    }
    secret_scanning_push_protection = {
      status = "enabled"
    }
  }

  # Access control
  team_permissions = {
    "developers"     = "push"
    "senior-devs"    = "maintain"
    "platform-team"  = "admin"
  }

  collaborator_permissions = {
    "external-consultant" = "pull"
  }

  # Branch protection with rulesets
  repository_rulesets = {
    "main-branch-rules" = {
      target      = "branch"
      enforcement = "active"
      
      conditions = {
        ref_name = {
          include = ["main"]
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
            { context = "continuous-integration" },
            { context = "security-scan" },
            { context = "code-quality" }
          ]
          strict_required_status_checks_policy = true
        }
        
        commit_message_pattern = {
          pattern  = "^(feat|fix|docs|style|refactor|test|chore)(\\(.+\\))?: .{1,50}"
          operator = "regex"
          name     = "Conventional Commits"
        }
        
        required_signatures     = true
        required_linear_history = true
        deletion                = true
        non_fast_forward        = true
      }
    }
  }

  # Deploy keys
  deploy_keys = {
    "production-deploy" = {
      key       = var.production_deploy_key
      read_only = false
    }
    "staging-deploy" = {
      key       = var.staging_deploy_key
      read_only = true
    }
  }

  # Repository files
  repository_files = {
    ".github/CODEOWNERS" = {
      content = file("${path.module}/files/CODEOWNERS")
    }
    ".github/pull_request_template.md" = {
      content = file("${path.module}/files/pull_request_template.md")
    }
    "CONTRIBUTING.md" = {
      content = file("${path.module}/files/CONTRIBUTING.md")
    }
  }

  # Environments
  environments = {
    "staging" = {
      wait_timer          = 5
      can_admins_bypass   = true
      prevent_self_review = false
      
      deployment_branch_policy = {
        protected_branches = true
      }
      
      secrets = {
        "DATABASE_URL" = var.staging_database_url
      }
      
      variables = {
        "ENVIRONMENT" = "staging"
      }
    }
    
    "production" = {
      wait_timer          = 30
      can_admins_bypass   = false
      prevent_self_review = true
      
      reviewers = {
        teams = [data.github_team.platform_team.id]
      }
      
      deployment_branch_policy = {
        protected_branches     = true
        custom_branch_policies = false
      }
      
      secrets = {
        "DATABASE_URL" = var.production_database_url
      }
      
      variables = {
        "ENVIRONMENT" = "production"
      }
    }
  }

  # Repository-level secrets and variables
  repository_secrets = {
    "SHARED_API_KEY" = var.shared_api_key
  }

  repository_variables = {
    "PROJECT_NAME"    = "complete-example"
    "DEFAULT_REGION"  = "us-east-1"
  }

  # Webhooks
  webhooks = {
    "ci-system" = {
      url          = "https://ci.example.com/hooks/github"
      content_type = "json"
      events       = ["push", "pull_request", "release"]
      active       = true
    }
    
    "slack-notifications" = {
      url          = var.slack_webhook_url
      content_type = "json"
      events       = ["issues", "pull_request", "push"]
      active       = true
    }
  }

  # GitHub Pages
  pages = {
    source = {
      branch = "gh-pages"
      path   = "/"
    }
    build_type = "workflow"
    cname      = "docs.example.com"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| opentofu | >= 1.8.0 |
| github | >= 6.3.0 |

## Providers

| Name | Version |
|------|---------|
| github | >= 6.3.0 |

## Inputs

### Required Inputs

| Name | Description | Type |
|------|-------------|------|
| name | The name of the repository | `string` |

### Optional Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| description | A description of the repository | `string` | `null` |
| visibility | The visibility of the repository | `string` | `"private"` |
| homepage_url | URL of the repository's homepage | `string` | `null` |
| archived | Set to true to archive the repository | `bool` | `false` |
| archive_on_destroy | Set to true to archive instead of delete | `bool` | `false` |
| has_issues | Enable GitHub Issues | `bool` | `true` |
| has_projects | Enable GitHub Projects | `bool` | `true` |
| has_wiki | Enable GitHub Wiki | `bool` | `true` |
| vulnerability_alerts | Enable security alerts | `bool` | `true` |
| topics | List of topics to apply | `list(string)` | `[]` |
| default_topics | Default topics always applied | `list(string)` | `["opentofu", "terraform", "infrastructure"]` |

For a complete list of inputs, see the [variables.tf](./variables.tf) file.

## Outputs

### Repository Information

| Name | Description |
|------|-------------|
| repository_id | The ID of the created repository |
| repository_name | The name of the created repository |
| repository_full_name | The full name (owner/name) |
| html_url | The URL of the repository |
| ssh_clone_url | SSH clone URL |
| http_clone_url | HTTP clone URL |

For a complete list of outputs, see the [outputs.tf](./outputs.tf) file.

## Examples

See the [examples/](./examples/) directory for complete working examples:

- [Basic Repository](./examples/basic/) - Simple repository setup
- [Advanced Repository](./examples/advanced/) - Repository with branch protection and teams
- [Complete Repository](./examples/complete/) - All features enabled

## Testing

This module includes OpenTofu native tests. Run them with:

```bash
task test
```

## Development

This module uses a comprehensive development workflow. Available tasks:

```bash
# Show available tasks
task --list

# Run pre-commit hooks
task pre

# Scan for secrets
task hog

# Run tests
task test

# Update documentation
task docs

# Clean up
task clean
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run `task pre` to validate
5. Submit a pull request

## Migration from Legacy Branch Protection

If you're using the legacy `branch_protection` variable, consider migrating to `repository_rulesets` for better functionality:

### Legacy (deprecated):
```hcl
branch_protection = {
  "main" = {
    require_pull_request_reviews    = true
    required_approving_review_count = 2
    require_code_owner_reviews      = true
  }
}
```

### Modern (recommended):
```hcl
repository_rulesets = {
  "main-protection" = {
    target      = "branch"
    enforcement = "active"
    
    conditions = {
      ref_name = {
        include = ["main"]
      }
    }
    
    rules = {
      pull_request = {
        required_approving_review_count = 2
        require_code_owner_review       = true
      }
    }
  }
}
```

## License

This module is licensed under the MIT License. See [LICENSE](./LICENSE) for details.

## Authors

Maintained by [dadandlad-co](https://github.com/dadandlad-co).

## Changelog

See [CHANGELOG.md](./CHANGELOG.md) for version history and changes.