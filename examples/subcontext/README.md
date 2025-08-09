# Subcontext Example

This example demonstrates how to use the terraform-external-context module to create hierarchical contexts, where a failover environment inherits configuration from a primary environment while overriding specific settings.

## Overview

This example creates two contexts:

1. **Primary Context**: Creates a base context with full configuration
2. **Failover Context**: Inherits from the primary context but overrides environment-specific settings

## Architecture

```
Primary Context (ck-multi-qapr)
├── namespace: "ck"
├── name: "multi"
├── environment: "qapr" 
└── environment_name: "QA Primary"

Failover Context (ck-multi-qafo) 
├── inherits all settings from Primary Context
├── environment: "qafo" (overridden)
└── environment_name: "QA Failover" (overridden)
```

## Key Features Demonstrated

- **Context Inheritance**: Using the `context` input to pass configuration from one module instance to another
- **Selective Override**: Changing only specific values while preserving the rest
- **Name Prefix Generation**: How different environments produce different name prefixes
- **Tag Inheritance**: How tags are inherited and can be augmented

## Usage

```bash
# Initialize and plan
terraform init
terraform plan

# Apply the configuration  
terraform apply

# View the outputs to see the differences
terraform output
```

## Expected Outputs

The example will show:

- **Primary name prefix**: `ck-multi-qapr`
- **Failover name prefix**: `ck-multi-qafo`
- **Inherited tags**: Both contexts will have the same base tags
- **Environment-specific differences**: Only the environment-related values will differ

## Key Concepts

### Context Inheritance

```hcl
# Primary context - defines all base configuration
module "primary_context" {
  source = "../../"
  
  namespace        = "ck"
  name             = "multi"
  environment      = "qapr"
  environment_name = "QA Primary"
  
  # ... all other configuration
}

# Failover context - inherits from primary, overrides only what's needed
module "failover_context" {
  source = "../../"
  
  context = module.primary_context.context  # Inherit everything
  
  # Override only environment-specific settings
  environment      = "qafo"
  environment_name = "QA Failover"
}
```

### Name Prefix Behavior

With the same namespace and name, but different environments:
- Primary: `ck-multi-qapr`
- Failover: `ck-multi-qafo`

This allows resources in both environments to follow the same naming pattern while remaining distinct.

### Tag Inheritance and Override

Both contexts will have identical base tags, but can have environment-specific additions through `additional_tags` and `additional_data_tags`.

## Files

- `main.tf` - Module instantiations showing context inheritance
- `variables.tf` - Input variable definitions
- `outputs.tf` - Outputs comparing both contexts
- `versions.tf` - Provider version constraints
- `terraform.auto.tfvars` - Example variable values
- `README.md` - This documentation

## Use Cases

This pattern is useful for:

- **Multi-environment deployments**: Dev, staging, production with shared configuration
- **Disaster recovery**: Primary and failover regions with identical setup
- **Multi-tenant applications**: Shared configuration with tenant-specific overrides
- **Feature branches**: Temporary environments that inherit from main branch configuration
