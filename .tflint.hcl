# TFLint configuration for OpenTofu
# https://github.com/terraform-linters/tflint

config {
  # Enable module inspection
  module = true
  
  # Disable default rules that are not applicable to OpenTofu
  disabled_by_default = false
  
  # Set the format of the output
  format = "compact"
  
  # Enable colored output
  force = false
}

# Core TFLint rules
rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_deprecated_index" {
  enabled = true
}

rule "terraform_deprecated_interpolation" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_module_pinned_source" {
  enabled = true
  style   = "semver"
}

rule "terraform_module_version" {
  enabled = true
  exact   = false
}

rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_standard_module_structure" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_unused_required_providers" {
  enabled = true
}

# GitHub Provider specific rules
plugin "terraform" {
  enabled = true
  version = "0.5.0"
  source  = "github.com/terraform-linters/tflint-ruleset-terraform"
}

# Custom rules for GitHub repositories
rule "terraform_workspace_remote" {
  enabled = false  # We don't use remote workspaces
}

# Variable validation rules
rule "terraform_variable_separate_type_description" {
  enabled = true
}

# Output validation rules  
rule "terraform_output_separate_description" {
  enabled = true
}

# Resource naming conventions
rule "terraform_resource_missing_name" {
  enabled = true
}

# Security rules
rule "terraform_sensitive_variable_no_default" {
  enabled = true
}