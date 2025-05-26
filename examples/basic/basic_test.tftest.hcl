#----------------------------------------------------------------------------
# OpenTofu Tests for GitHub Repository Module
#----------------------------------------------------------------------------

# Test basic repository creation
run "basic_repository_test" {
  command = plan

  variables {
    name        = "test-repo-basic"
    description = "Test repository for basic functionality"
    visibility  = "private"
    
    has_issues   = true
    has_projects = false
    has_wiki     = false
    
    topics = ["test", "basic"]
  }

  # Test that repository is configured correctly
  assert {
    condition     = github_repository.repository.name == "test-repo-basic"
    error_message = "Repository name should be 'test-repo-basic'"
  }

  assert {
    condition     = github_repository.repository.description == "Test repository for basic functionality"
    error_message = "Repository description should match input"
  }

  assert {
    condition     = github_repository.repository.visibility == "private"
    error_message = "Repository should be private"
  }

  assert {
    condition     = github_repository.repository.has_issues == true
    error_message = "Repository should have issues enabled"
  }

  assert {
    condition     = github_repository.repository.has_projects == false
    error_message = "Repository should have projects disabled"
  }

  assert {
    condition     = contains(github_repository.repository.topics, "test")
    error_message = "Repository should have 'test' topic"
  }

  assert {
    condition     = contains(github_repository.repository.topics, "opentofu")
    error_message = "Repository should have default 'opentofu' topic"
  }
}

# Test repository with branch protection
run "branch_protection_test" {
  command = plan

  variables {
    name        = "test-repo-protected"
    description = "Test repository with branch protection"
    visibility  = "private"
    
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
            required_approving_review_count = 1
            require_code_owner_review       = true
          }
          
          required_status_checks = {
            required_checks = [
              {
                context = "ci/test"
              }
            ]
            strict_required_status_checks_policy = true
          }
          
          deletion = true
        }
      }
    }
  }

  # Test that ruleset is created
  assert {
    condition     = length(github_repository_ruleset.rulesets) == 1
    error_message = "Should create exactly one repository ruleset"
  }

  assert {
    condition     = github_repository_ruleset.rulesets["main-protection"].name == "main-protection"
    error_message = "Ruleset should be named 'main-protection'"
  }

  assert {
    condition     = github_repository_ruleset.rulesets["main-protection"].target == "branch"
    error_message = "Ruleset should target branches"
  }

  assert {
    condition     = github_repository_ruleset.rulesets["main-protection"].enforcement == "active"
    error_message = "Ruleset should be actively enforced"
  }
}

# Test repository with team permissions
run "team_permissions_test" {
  command = plan

  variables {
    name        = "test-repo-teams"
    description = "Test repository with team permissions"
    visibility  = "private"
    
    team_permissions = {
      "developers" = "push"
      "admins"     = "admin"
    }
  }

  # Test that team permissions are configured
  assert {
    condition     = length(github_team_repository.teams) == 2
    error_message = "Should create team permissions for 2 teams"
  }

  assert {
    condition     = github_team_repository.teams["developers"].permission == "push"
    error_message = "Developers team should have push permission"
  }

  assert {
    condition     = github_team_repository.teams["admins"].permission == "admin"
    error_message = "Admins team should have admin permission"
  }
}

# Test repository with files
run "repository_files_test" {
  command = plan

  variables {
    name        = "test-repo-files"
    description = "Test repository with custom files"
    visibility  = "private"
    
    repository_files = {
      ".github/CODEOWNERS" = {
        content = "* @team/maintainers\n"
      }
      "README.md" = {
        content        = "# Test Repository\n\nThis is a test."
        commit_message = "Add README"
      }
    }
  }

  # Test that files are created
  assert {
    condition     = length(github_repository_file.files) == 2
    error_message = "Should create 2 repository files"
  }

  assert {
    condition     = github_repository_file.files[".github/CODEOWNERS"].file == ".github/CODEOWNERS"
    error_message = "CODEOWNERS file should be created"
  }

  assert {
    condition     = github_repository_file.files["README.md"].file == "README.md"
    error_message = "README.md file should be created"
  }

  assert {
    condition     = github_repository_file.files["README.md"].commit_message == "Add README"
    error_message = "README.md should have custom commit message"
  }
}

# Test repository with environments
run "environments_test" {
  command = plan

  variables {
    name        = "test-repo-envs"
    description = "Test repository with environments"
    visibility  = "private"
    
    environments = {
      "staging" = {
        wait_timer = 0
        variables = {
          "ENV" = "staging"
        }
      }
      "production" = {
        wait_timer          = 30
        prevent_self_review = true
        variables = {
          "ENV" = "production"
        }
      }
    }
  }

  # Test that environments are created
  assert {
    condition     = length(github_repository_environment.environments) == 2
    error_message = "Should create 2 environments"
  }

  assert {
    condition     = github_repository_environment.environments["staging"].wait_timer == 0
    error_message = "Staging environment should have no wait timer"
  }

  assert {
    condition     = github_repository_environment.environments["production"].wait_timer == 30
    error_message = "Production environment should have 30s wait timer"
  }

  assert {
    condition     = github_repository_environment.environments["production"].prevent_self_review == true
    error_message = "Production environment should prevent self-review"
  }

  # Test environment variables
  assert {
    condition     = length(github_actions_environment_variable.environment_variables) == 2
    error_message = "Should create 2 environment variables"
  }
}

# Test merge settings
run "merge_settings_test" {
  command = plan

  variables {
    name        = "test-repo-merge"
    description = "Test repository merge settings"
    visibility  = "private"
    
    allow_merge_commit = false
    allow_squash_merge = true
    allow_rebase_merge = true
    allow_auto_merge   = true
    
    delete_branch_on_merge = true
    
    squash_merge_commit_title   = "PR_TITLE"
    squash_merge_commit_message = "COMMIT_MESSAGES"
  }

  # Test merge settings
  assert {
    condition     = github_repository.repository.allow_merge_commit == false
    error_message = "Merge commits should be disabled"
  }

  assert {
    condition     = github_repository.repository.allow_squash_merge == true
    error_message = "Squash merge should be enabled"
  }

  assert {
    condition     = github_repository.repository.allow_rebase_merge == true
    error_message = "Rebase merge should be enabled"
  }

  assert {
    condition     = github_repository.repository.allow_auto_merge == true
    error_message = "Auto merge should be enabled"
  }

  assert {
    condition     = github_repository.repository.delete_branch_on_merge == true
    error_message = "Delete branch on merge should be enabled"
  }

  assert {
    condition     = github_repository.repository.squash_merge_commit_title == "PR_TITLE"
    error_message = "Squash merge commit title should be PR_TITLE"
  }
}

# Test security settings
run "security_settings_test" {
  command = plan

  variables {
    name        = "test-repo-security"
    description = "Test repository security settings"
    visibility  = "private"
    
    vulnerability_alerts = true
    
    security_and_analysis = {
      secret_scanning = {
        status = "enabled"
      }
      secret_scanning_push_protection = {
        status = "enabled"
      }
    }
  }

  # Test security settings
  assert {
    condition     = github_repository.repository.vulnerability_alerts == true
    error_message = "Vulnerability alerts should be enabled"
  }

  # Test that security_and_analysis block is configured
  assert {
    condition     = github_repository.repository.security_and_analysis != null
    error_message = "Security and analysis should be configured"
  }
}

# Test template repository usage
run "template_repository_test" {
  command = plan

  variables {
    name        = "test-repo-template"
    description = "Test repository created from template"
    visibility  = "private"
    
    template = {
      owner                = "dadandlad-co"
      repository           = "template-repo"
      include_all_branches = false
    }
  }

  # Test template configuration
  assert {
    condition     = github_repository.repository.template != null
    error_message = "Template should be configured"
  }

  # Test that auto_init is disabled when using template
  assert {
    condition     = github_repository.repository.auto_init == false
    error_message = "Auto init should be disabled when using template"
  }
}

# Test validation failures
run "validation_test" {
  command = plan
  
  variables {
    name        = "Test-Invalid-Name-With-Capitals"
    description = "This should fail validation"
    visibility  = "private"
  }

  expect_failures = [
    var.name,
  ]
}