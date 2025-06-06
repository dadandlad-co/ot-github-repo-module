#----------------------------------------------------------------------------
# versions.tf - OpenTofu GitHub Repository Module
#----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.8.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 6.3.0"
    }
  }
}
