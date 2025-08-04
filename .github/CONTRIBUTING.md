# Contributing

Thank you for your interest in contributing to this Terraform module! We welcome contributions from the community and appreciate your help in making this module better.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Making Changes](#making-changes)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)
- [Style Guidelines](#style-guidelines)
- [Reporting Issues](#reporting-issues)

## Code of Conduct

This project adheres to a code of conduct. By participating, you are expected to uphold this code. Please be respectful and constructive in all interactions.

## Getting Started

1. Fork the repository on GitHub
2. Clone your fork locally
3. Create a new branch for your changes
4. Make your changes
5. Test your changes
6. Submit a pull request

## Development Setup

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.5
- [Go](https://golang.org/dl/) >= 1.19 (for testing)
- AWS CLI configured with appropriate credentials
- Git

### Local Development

1. Clone your fork:
   ```bash
   git clone https://github.com/YOUR-USERNAME/terraform-replace-me.git
   cd terraform-replace-me
   ```

2. Create a new branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Making Changes

### Types of Contributions

- **Bug fixes**: Fix issues or unexpected behavior
- **New features**: Add new functionality to the module
- **Documentation**: Improve README, examples, or code comments
- **Tests**: Add or improve test coverage
- **Performance**: Optimize existing functionality

### Development Workflow

1. **Understand the existing code**: Review the current implementation and understand how it works
2. **Plan your changes**: For larger changes, consider opening an issue first to discuss the approach
3. **Write your code**: Follow the style guidelines and best practices
4. **Test your changes**: Ensure all tests pass and add new tests if needed
5. **Update documentation**: Update README, variable descriptions, and examples as needed

## Testing

### Running Tests

This module uses [Terratest](https://terratest.gruntwork.io/) for testing:

```bash
# Run all tests
cd test
go test -v -timeout 30m

# Run specific test
go test -v -timeout 30m -run TestVpcModule
```

### Test Structure

- Tests are located in the `test/` directory
- Test examples are in the `examples/` directory
- Tests should use `t.Parallel()` for better performance
- Always include proper cleanup (defer terraform.Destroy)

### Manual Testing

Before submitting changes:

1. Run `terraform fmt` on all modified files
2. Run `terraform validate` on all modified files
3. Test your changes with a real AWS account (use a test environment)
4. Verify that existing functionality still works

## Submitting Changes

### Pull Request Process

1. **Update documentation**: Ensure README, variables, and outputs are up to date
2. **Add tests**: Include tests for new functionality
3. **Follow conventions**: Use the established code style and patterns
4. **Write clear commit messages**: Use descriptive commit messages
5. **Fill out PR template**: Complete all sections of the pull request template

### Pull Request Requirements

- [ ] Code follows the style guidelines
- [ ] Tests pass locally
- [ ] Documentation is updated
- [ ] Changes are backward compatible (or breaking changes are clearly marked)
- [ ] Commit messages are clear and descriptive

### Review Process

1. Automated checks will run on your PR
2. A maintainer will review your changes
3. Address any feedback or requested changes
4. Once approved, your PR will be merged

## Style Guidelines

### Terraform Code Style

Follow the guidelines in [`.ruler/terraform-style.md`](.ruler/terraform-style.md):

- Use `terraform fmt` for consistent formatting
- Use snake_case for all identifiers
- Include descriptions for all variables and outputs
- Use explicit type constraints
- Follow the established file organization

### Example:

```hcl
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr_block, 0))
    error_message = "VPC CIDR block must be a valid IPv4 CIDR."
  }
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}
```

### Documentation Style

- Use clear, concise language
- Include examples for complex configurations
- Keep README up to date with changes
- Use proper Markdown formatting

### Commit Message Format

Use clear, descriptive commit messages:

```
feat: add support for VPC flow logs

- Add vpc_flow_logs_enabled variable
- Create CloudWatch log group for flow logs
- Update documentation and examples
```

**Commit types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

## Reporting Issues

### Before Creating an Issue

1. Check existing issues to avoid duplicates
2. Ensure you're using a supported Terraform version
3. Test with the latest version of the module
4. Gather all relevant information (versions, configurations, error messages)

### Issue Types

Use the appropriate issue template:

- **Bug Report**: For reporting bugs or unexpected behavior
- **Feature Request**: For suggesting new features
- **Question**: For usage questions or help
- **Documentation**: For documentation improvements

### Security Issues

For security-related issues, please email the maintainers directly rather than creating a public issue.

## Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terratest Documentation](https://terratest.gruntwork.io/)
- [HashiCorp Style Guide](https://developer.hashicorp.com/terraform/language/style)

## Questions?

If you have questions about contributing, feel free to:

1. Open an issue with the "question" label
2. Check existing issues and discussions
3. Review the documentation

Thank you for contributing!