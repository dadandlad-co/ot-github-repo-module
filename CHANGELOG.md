# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release of OpenTofu GitHub Repository Module
- Comprehensive GitHub repository management
- Modern repository rulesets support (replaces legacy branch protection)
- Team and collaborator permission management
- GitHub Actions secrets and variables support
- Environment management with protection rules
- Deploy keys management
- Webhook configuration
- Repository file management
- GitHub Pages configuration
- Security and analysis settings
- Complete test suite with OpenTofu native testing
- Comprehensive documentation and examples
- Pre-commit hooks and development workflow
- CI/CD integration with GitHub Actions

### Features
- **Repository Management**: Full repository lifecycle management
- **Access Control**: Team permissions, collaborator access, and deploy keys
- **Branch Protection**: Modern repository rulesets with advanced rules
- **CI/CD Integration**: GitHub Actions secrets, variables, and environments
- **Security**: Vulnerability alerts, secret scanning, and push protection
- **Automation**: Webhooks for external integrations
- **Documentation**: GitHub Pages support and repository files
- **Developer Experience**: Comprehensive examples and testing

### Technical Details
- Requires OpenTofu >= 1.8.0
- Uses GitHub Provider >= 6.3.0
- Supports all modern GitHub features
- Backward compatible with legacy branch protection
- Comprehensive input validation
- Detailed outputs for integration

## [1.0.0] - TBD

### Added
- Initial stable release

---

## Development Notes

### Migration from Legacy Branch Protection

Users migrating from legacy `branch_protection` to modern `repository_rulesets` should:

1. Review existing branch protection rules
2. Map them to equivalent ruleset configurations
3. Test in a non-production environment
4. Gradually migrate repositories

### Breaking Changes

None currently planned for v1.x series.

### Deprecation Notices

- Legacy `branch_protection` variable is still supported but `repository_rulesets` is recommended
- GitHub's branch protection API may be deprecated in favor of rulesets in the future

### Security Considerations

- Always use secrets for sensitive values
- Enable vulnerability alerts and secret scanning
- Use environment protection rules for production deployments
- Implement proper CODEOWNERS for sensitive files
- Consider using signed commits for additional security
