# Brockhof Cloud Context Terraform Module Guide for AI Agents

What the goal of this module is.

## Components

### Context
- Provides name prefix standardization with output value named `named_prefix`
- Provides standardized/consistent tags/labels with output values named `tags` and `data_tags`
- Support AWS, Azure, and GCP naming and tagging conventions

### Naming
- Name prefix compilies with the Brockhoff Terraform module standard expected by all modules.
  - Regex: `/^[a-z][a-z0-9-]{0,14}[a-z0-9]$/`
- Name can be inputted one of two ways:
  - `namespace`, `name`, and `environment` variables joined with a hyphen.
  - `name` variable only which is used only if `namespace` and `environment` are not provided.

