---
Source: .ruler/instructions.md
---
# CLOUD XXX Terraform Module Guide for AI Agents

What the goal of this module is.

## Components

### Component 1
- Requirement
- Requirement

### Component 2
- Requirement
- Requirement

---
Source: .ruler/terraform-git.md
---
# AI Agent Git Operations for Terraform Repositories

## Core Principles

**Simplicity First**: Each operation should have a single, clear purpose. Avoid complecting git operations with unrelated concerns.

**Composable Workflow**: Each stage builds independently on the previous, allowing for easy debugging and iteration.

## Branch Management

### Creating Branches
- **Format**: `feature/descriptive-name` or `fix/issue-description`
- **Source**: Always branch from `main`
- **Naming**: Use kebab-case, be specific about the change

```bash
git checkout main
git pull origin main
git checkout -b feature/add-to-module
```

### Keeping Branches Current
- **Method**: Rebase only (preserve linear history)
- **Frequency**: Daily, or before any major work session
- **Conflict Resolution**: Address conflicts immediately

```bash
git fetch origin
git rebase origin/main
```

## Pre-Commit Standards

### Complete Validation Pipeline (Recommended)
```bash
# Single command runs complete validation: format, validate, lint, test, docs
make validate
```

### Individual Validation Steps (If Needed)
Use these for specific validation needs:

1. **Code Formatting**
   ```bash
   make format
   ```

2. **Module & Example Validation**
   ```bash
   make check
   ```

3. **Linting**
   ```bash
   make lint
   ```

4. **Documentation Generation**
   ```bash
   make docs
   ```

5. **Test Execution**
   ```bash
   make test
   ```

## Commit Standards

### Message Format
Follow [Conventional Commits 1.0.0](https://www.conventionalcommits.org/):

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Examples
```
feat(vpc): add multi-az subnet configuration
fix(security-group): resolve circular dependency issue
docs(readme): update module usage examples
test(vpc): add integration test for NAT gateway
```

### Commit Scope
- **Atomic Changes**: One logical change per commit
- **Complete Units**: Each commit should leave the repository in a working state
- **Clear Intent**: Commit message should explain *why*, not just *what*

## Pull Request Workflow

### Pre-PR Validation
Ensure all pre-commit checks pass:
```bash
# Complete validation pipeline
make validate
```

### Alternative: Pre-commit Only (No Tests)
For quick validation without running AWS-dependent tests:
```bash
make pre-commit
```

### PR Requirements
1. **Title**: Must follow Conventional Commits format
2. **Description**: Complete all GitHub template sections
3. **Scope**: Single concern per PR (avoid complecting multiple features)
4. **Size**: Prefer smaller, focused PRs over large, complex ones

### PR Template Sections (All Required)
- [ ] **Summary**: What does this PR accomplish?
- [ ] **Changes**: Specific modifications made
- [ ] **Testing**: How was this validated?
- [ ] **Breaking Changes**: Any backwards compatibility concerns?
- [ ] **Documentation**: What docs were updated?

## Quality Gates

### Automated Checks (Must Pass)
Run `make validate` to ensure all of the following pass:
- Terraform formatting (`make format`)
- Module & example validation (`make check`)
- TFLint compliance (`make lint`)
- All tests passing (`make test`)
- Documentation generation (`make docs`)

### Manual Review Focus
- **Simplicity**: Is the solution as simple as possible?
- **Composition**: Are components properly decoupled?
- **Clarity**: Is the intent obvious from the code?
- **Testability**: Can changes be easily validated?

## Troubleshooting

### Common Issues
1. **Rebase Conflicts**: Resolve immediately, don't accumulate
2. **Test Failures**: Fix root cause, don't mask symptoms
3. **Lint Errors**: Address policy violations, don't suppress

### Recovery Patterns
```bash
# Reset to clean state if needed
git reset --hard origin/main

# Clean workspace
git clean -fd

# Clean Terraform temporary files
make clean
```

## Notes for AI Agents

### Recommended Workflow Commands
- **Development validation**: `make validate` (complete pipeline)
- **Quick checks**: `make pre-commit` (no tests, no AWS needed)
- **AWS session check**: `make check-aws` (verify AWS access before tests)
- **Module information**: `make status` (comprehensive project info)
- **Resource verification**: `make resource-count` (expected resource counts)
- **Cleanup**: `make clean` (remove temporary files)

### Best Practices
- **Fail Fast**: Use `make validate` to stop pipeline on first error
- **Context Preservation**: Use `make status` for project information gathering
- **Rollback Strategy**: Always know how to undo changes with git and `make clean`
- **AWS Validation**: Makefile automatically validates AWS session for tests
- **Efficiency**: Single commands replace multiple manual operations

---
Source: .ruler/terraform-module.md
---
# Terraform Module Guide for AI Agents

This guide emphasizes creating simple, composable Terraform modules that are easy to understand, use, and maintain.

## Module Design Philosophy

### Single Responsibility Principle
Each module should have **one reason to change**:

```hcl
# Good - VPC module handles only networking concerns
module "vpc" {
  source = "./modules/vpc"
  
  name       = var.network_name
  cidr_block = var.vpc_cidr
  
  availability_zones = var.azs
}

# Good - Separate module for compute concerns  
module "web_servers" {
  source = "./modules/ec2-asg"
  
  name     = var.app_name
  vpc_id   = module.vpc.vpc_id
  subnets  = module.vpc.private_subnet_ids
  
  min_size = var.instance_count
}

# Avoid - Module that handles everything
module "entire_application" {
  # Creates VPC, subnets, security groups, load balancers,
  # EC2 instances, RDS databases, S3 buckets, etc.
  # Too many responsibilities, hard to understand and reuse
}
```

### Composition Over Configuration
Design modules to **compose well together** rather than trying to handle every possible scenario:

```hcl
# Good - Focused modules that compose
module "database" {
  source = "./modules/rds"
  
  name     = "${var.app_name}-db"
  engine   = "postgres"
  subnets  = module.vpc.database_subnet_ids
  
  # Module focuses on database concerns only
}

module "app_servers" {
  source = "./modules/ec2-asg"
  
  name            = var.app_name
  subnets         = module.vpc.private_subnet_ids
  database_endpoint = module.database.endpoint
  
  # Module focuses on compute concerns only
}

# Avoid - Overly configurable single module
module "application_stack" {
  create_database    = var.needs_database
  create_cache       = var.needs_cache
  create_load_balancer = var.needs_lb
  database_engine    = var.db_engine
  # ... 50+ configuration options
  # Module tries to be everything to everyone
}
```

### Interface Clarity
Module interfaces should be **predictable and minimal**:

```hcl
# Good - Clear, essential inputs
variable "name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC where resources will be created"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for resource placement"
  type        = list(string)
}

# Good - Essential outputs
output "security_group_id" {
  description = "Security group ID for additional rules"
  value       = aws_security_group.main.id
}

output "instance_ids" {
  description = "EC2 instance IDs for monitoring"
  value       = aws_instance.main[*].id
}
```

## Interface Design Patterns

### Input Variables
Focus on **essential configuration** and provide sensible defaults:

```hcl
# Required inputs - things the module cannot decide
variable "name" {
  description = "Unique name for this instance of the module"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,15}$", var.name))
    error_message = "Name must be 2-16 characters, lowercase, start with letter."
  }
}

variable "vpc_id" {
  description = "VPC where resources will be created"
  type        = string
}

# Optional inputs with sensible defaults
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "enable_monitoring" {
  description = "Enable enhanced monitoring"
  type        = bool
  default     = true
}

# Complex configurations - use objects for related settings
variable "scaling_config" {
  description = "Auto scaling configuration"
  type = object({
    min_size         = number
    max_size         = number
    desired_capacity = number
  })
  default = {
    min_size         = 1
    max_size         = 3
    desired_capacity = 2
  }
}
```

### Feature Flags
Use **boolean flags** for optional functionality:

```hcl
variable "create_load_balancer" {
  description = "Create an Application Load Balancer"
  type        = bool
  default     = false
}

variable "enable_encryption" {
  description = "Enable encryption at rest"
  type        = bool
  default     = true
}

# Use feature flags in resource creation
resource "aws_lb" "main" {
  count = var.create_load_balancer ? 1 : 0
  
  name     = var.name
  subnets  = var.public_subnet_ids
  
  tags = local.common_tags
}
```

### Output Values
Provide outputs that **enable composition**:

```hcl
# Identity outputs - for referencing resources
output "vpc_id" {
  description = "VPC identifier"
  value       = aws_vpc.main.id
}

output "security_group_id" {
  description = "Security group identifier for additional rules"
  value       = aws_security_group.main.id
}

# Connection outputs - for dependent resources
output "database_endpoint" {
  description = "Database connection endpoint"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}

output "subnet_ids" {
  description = "Subnet IDs for resource placement"
  value       = aws_subnet.main[*].id
}

# Avoid outputs that expose implementation details
# output "internal_resource_arn" { ... }  # Not useful for composition
```

## Implementation Patterns

### Resource Naming
Create **consistent, predictable names**:

```hcl
locals {
  # Common naming prefix
  name_prefix = var.name
  
  # Consistent tagging
  common_tags = {
    Name          = var.name
    Environment   = var.environment
    Module        = "vpc"
    ManagedBy     = "terraform"
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

resource "aws_subnet" "private" {
  for_each = var.private_subnets
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-${each.key}"
    Type = "private"
  })
}
```

### Version Management
**Pin versions** for reliability:

```hcl
# versions.tf
terraform {
  required_version = ">= 1.5"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Track module version for debugging
locals {
  module_version = "1.2.3"  # Updated by CI/CD
}
```

### Data Source Patterns
**Centralize external dependencies** and make them explicit:

```hcl
# dependencies.tf - All external data in one place
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

# Use locals to make data available throughout module
locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  azs        = data.aws_availability_zones.available.names
}

# Pass to submodules rather than having them call data sources
module "subnets" {
  source = "./modules/subnets"
  
  availability_zones = local.azs
  account_id        = local.account_id
}
```

### Environment Configuration
**Simplify environment handling** with sensible categories:

```hcl
variable "environment" {
  description = "Environment type for resource sizing"
  type        = string
  default     = "development"
  
  validation {
    condition = contains([
      "development", "staging", "production"
    ], var.environment)
    error_message = "Environment must be development, staging, or production."
  }
}

# Use environment to set appropriate defaults
locals {
  instance_configs = {
    development = {
      instance_type = "t3.micro"
      min_size     = 1
      max_size     = 2
    }
    staging = {
      instance_type = "t3.small"
      min_size     = 2
      max_size     = 4
    }
    production = {
      instance_type = "t3.medium"
      min_size     = 3
      max_size     = 10
    }
  }
  
  config = local.instance_configs[var.environment]
}

resource "aws_launch_template" "main" {
  instance_type = local.config.instance_type
  # ...
}
```

## Repository Organization

### File Structure
**Separate concerns** into focused files:

```
terraform-aws-vpc/
├── main.tf              # Core VPC resources
├── subnets.tf           # Subnet resources
├── routing.tf           # Route tables and routes
├── security.tf          # Security groups and NACLs
├── variables.tf         # Input variables
├── outputs.tf           # Output values
├── locals.tf            # Local computations
├── versions.tf          # Version constraints
├── dependencies.tf      # External data sources
├── README.md            # Usage documentation
├── CHANGELOG.md         # Version history
├── examples/
│   ├── simple/          # Minimal configuration
│   └── complete/        # Full feature demo
├── modules/
│   └── nat-gateway/     # Optional submodules
└── test/
    ├── simple_test.go
    └── complete_test.go
```

### Example Organization
Provide **clear usage examples**:

**examples/simple/** - Minimal Configuration
```hcl
module "vpc" {
  source = "../../"
  
  name       = var.name
  cidr_block = "10.0.0.0/16"
  
  # Use all defaults for everything else
}
```

**examples/complete/** - Full Configuration
```hcl
module "vpc" {
  source = "../../"
  
  name       = var.name
  cidr_block = var.cidr_block
  
  availability_zones = var.availability_zones
  
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  
  enable_nat_gateway = var.enable_nat_gateway
  enable_vpn_gateway = var.enable_vpn_gateway
  
  tags = var.tags
}
```

### Branching Strategy
Keep it **simple and predictable**:

- **main** - Production-ready releases
- **feature/feature-name** - New features
- **fix/issue-description** - Bug fixes

Use **semantic versioning** (v1.0.0, v1.1.0, v1.1.1) and tag releases on main.

## Provider-Specific Patterns

### AWS Best Practices

#### IAM Policies
Use **policy documents** for maintainability:

```hcl
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "main" {
  name               = "${var.name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
```

#### Encryption
**Default to encryption** with customer-managed keys:

```hcl
variable "kms_key_id" {
  description = "KMS key for encryption (creates new key if not provided)"
  type        = string
  default     = null
}

resource "aws_kms_key" "main" {
  count = var.kms_key_id == null ? 1 : 0
  
  description = "Key for ${var.name}"
  tags        = local.common_tags
}

locals {
  kms_key_id = var.kms_key_id != null ? var.kms_key_id : aws_kms_key.main[0].arn
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id
  
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = local.kms_key_id
      sse_algorithm     = "aws:kms"
    }
  }
}
```

#### Monitoring
**Create log groups explicitly**:

```hcl
resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/lambda/${var.name}"
  retention_in_days = var.log_retention_days
  
  tags = local.common_tags
}

resource "aws_lambda_function" "main" {
  # ... other configuration
  
  depends_on = [aws_cloudwatch_log_group.main]
}
```

## Avoiding Complexity Traps

### Over-Configuration
```hcl
# Trap - Too many options
variable "database_config" {
  type = object({
    engine                = optional(string, "postgres")
    engine_version        = optional(string, "13.7")
    instance_class        = optional(string, "db.t3.micro")
    allocated_storage     = optional(number, 20)
    max_allocated_storage = optional(number, 100)
    storage_type          = optional(string, "gp2")
    storage_encrypted     = optional(bool, true)
    # ... 20+ more options
  })
}

# Better - Essential options with environment-based defaults
variable "database_size" {
  description = "Database size category"
  type        = string
  default     = "small"
  
  validation {
    condition     = contains(["small", "medium", "large"], var.database_size)
    error_message = "Size must be small, medium, or large."
  }
}

locals {
  db_configs = {
    small  = { instance_class = "db.t3.micro", storage = 20 }
    medium = { instance_class = "db.t3.small", storage = 100 }
    large  = { instance_class = "db.t3.medium", storage = 500 }
  }
}
```

### Implicit Dependencies
```hcl
# Trap - Hidden dependencies
data "aws_security_group" "existing" {
  name = "${var.environment}-web-sg"  # Assumes naming convention
}

# Better - Explicit inputs
variable "security_group_id" {
  description = "Security group ID for instances"
  type        = string
}
```

### Tight Coupling
```hcl
# Trap - Module knows too much about its environment
resource "aws_instance" "web" {
  # Assumes specific VPC structure
  subnet_id = data.aws_subnet.web.id
  
  # Assumes specific security group naming
  vpc_security_group_ids = [data.aws_security_group.web.id]
}

# Better - Accept dependencies as inputs
variable "subnet_id" {
  description = "Subnet for instance placement"
  type        = string
}

variable "security_group_ids" {
  description = "Security groups for the instance"
  type        = list(string)
}
```

## AI Agent Guidelines

### Module Boundary Analysis
When designing a module, ask:

1. **Single Purpose**: What is the **one thing** this module should do well?
2. **Change Triggers**: What would cause this module to need modification?
3. **Composition**: How will this module work with others?
4. **Interface Clarity**: Can users predict what this module will create?

```hcl
# Good module boundary - focused on VPC networking
module "vpc" {
  # Creates: VPC, subnets, route tables, internet gateway
  # Purpose: Provide network foundation
  # Interface: CIDR blocks in, subnet IDs out
}

# Good module boundary - focused on compute cluster  
module "web_cluster" {
  # Creates: Launch template, auto scaling group, load balancer
  # Purpose: Provide scalable web application hosting
  # Interface: VPC details in, endpoints out
}

# Poor module boundary - does everything
module "web_application" {
  # Creates: VPC, subnets, security groups, load balancer,
  #          auto scaling group, RDS, S3, CloudFront, Route53
  # Too many responsibilities, hard to understand and reuse
}
```

### Interface Design Process

1. **Start with Outputs**: What do consumers need from this module?
2. **Work Backwards to Inputs**: What information is required to produce those outputs?
3. **Minimize Surface Area**: Remove any inputs that aren't essential
4. **Group Related Settings**: Use objects for cohesive configuration

```hcl
# Step 1: Define what consumers need
output "cluster_endpoint" {
  description = "Load balancer endpoint for the application"
  value       = aws_lb.main.dns_name
}

output "security_group_id" {
  description = "Security group for additional rules"
  value       = aws_security_group.main.id
}

# Step 2: Work backwards to required inputs
variable "name" {
  description = "Name for the cluster resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC where cluster will be created"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for load balancer and instances"
  type        = list(string)
}

# Step 3: Group related optional settings
variable "scaling" {
  description = "Auto scaling configuration"
  type = object({
    min_size         = number
    max_size         = number
    desired_capacity = number
  })
  default = {
    min_size         = 2
    max_size         = 6
    desired_capacity = 3
  }
}
```

### Code Generation Patterns

#### Start Simple, Add Complexity Gradually
```hcl
# Phase 1: Core functionality
resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  
  tags = {
    Name = var.name
  }
}

# Phase 2: Add essential features
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = merge(var.tags, {
    Name = var.name
  })
}

# Phase 3: Add operational features (when needed)
resource "aws_flow_log" "vpc" {
  count = var.enable_flow_logs ? 1 : 0
  
  iam_role_arn    = aws_iam_role.flow_log[0].arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_log[0].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id
}
```

#### Use Locals for Complex Logic
```hcl
# Extract complex expressions to locals
locals {
  # Calculate subnet configurations
  subnet_configs = {
    for az_idx, az in var.availability_zones : az => {
      private_cidr = cidrsubnet(var.cidr_block, 8, az_idx)
      public_cidr  = cidrsubnet(var.cidr_block, 8, az_idx + 100)
    }
  }
  
  # Determine if NAT gateways are needed
  needs_nat_gateway = var.enable_nat_gateway && length(var.private_subnets) > 0
}

resource "aws_subnet" "private" {
  for_each = var.create_private_subnets ? local.subnet_configs : {}
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.private_cidr
  availability_zone = each.key
}
```

### Refactoring Strategies

#### Extract Submodules When Needed
```hcl
# Before - Everything in one module
resource "aws_vpc" "main" { ... }
resource "aws_subnet" "private" { ... }
resource "aws_subnet" "public" { ... }
resource "aws_route_table" "private" { ... }
resource "aws_route_table" "public" { ... }
resource "aws_nat_gateway" "main" { ... }
resource "aws_internet_gateway" "main" { ... }
# 50+ more resources...

# After - Extracted submodules
module "subnets" {
  source = "./modules/subnets"
  
  vpc_id             = aws_vpc.main.id
  availability_zones = var.availability_zones
  private_cidrs      = var.private_subnet_cidrs
  public_cidrs       = var.public_subnet_cidrs
}

module "routing" {
  source = "./modules/routing"
  
  vpc_id           = aws_vpc.main.id
  private_subnets  = module.subnets.private_subnet_ids
  public_subnets   = module.subnets.public_subnet_ids
  enable_nat       = var.enable_nat_gateway
}
```

#### Simplify Variable Structures
```hcl
# Before - Complex nested structure
variable "subnets" {
  type = map(object({
    cidr              = string
    availability_zone = string
    type             = string
    route_table_id   = optional(string)
    nat_gateway_id   = optional(string)
    # ... many more optional fields
  }))
}

# After - Simplified with sensible defaults
variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones for subnets"
  type        = list(string)
}
```

### Testing Integration
Design modules to be **easily testable**:

```hcl
# Include test-friendly outputs
output "resource_count" {
  description = "Number of resources created (for testing)"
  value = {
    subnets         = length(aws_subnet.private) + length(aws_subnet.public)
    route_tables    = length(aws_route_table.private) + length(aws_route_table.public)
    nat_gateways    = length(aws_nat_gateway.main)
  }
}

# Make resource creation predictable
locals {
  # Deterministic resource naming for tests
  expected_resources = [
    "aws_vpc.main",
    "aws_internet_gateway.main",
  ]
}
```

### Common Pitfalls to Avoid

1. **God Modules**: Modules that create too many different types of resources
2. **Configuration Overload**: Too many input variables that complect unrelated concerns
3. **Implicit Dependencies**: Modules that assume specific naming conventions or external resources
4. **Premature Optimization**: Adding complexity for hypothetical future needs
5. **Implementation Exposure**: Outputs that reveal internal implementation details

```hcl
# Avoid - God module
module "entire_app" {
  source = "./modules/everything"
  
  # Creates VPC, EC2, RDS, S3, Lambda, API Gateway, CloudFront...
  # Too many responsibilities
}

# Better - Focused modules
module "network" {
  source = "./modules/vpc"
  # Only network resources
}

module "compute" {
  source = "./modules/ec2-cluster"
  # Only compute resources
}

module "storage" {
  source = "./modules/rds"
  # Only database resources
}
```

### Documentation Standards

Generate clear documentation that explains **intent**, not just syntax:

```markdown
# VPC Module

Creates a VPC with public and private subnets across multiple availability zones.

## Usage

```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  
  name = "my-vpc"
  cidr = "10.0.0.0/16"
  
  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  
  enable_nat_gateway = true
}
```

## Design Decisions

- **Public subnets** have routes to the Internet Gateway for outbound internet access
- **Private subnets** route through NAT Gateways in public subnets  
- **One NAT Gateway per AZ** when `enable_nat_gateway = true` for high availability
- **DNS resolution enabled** by default for service discovery

## Composition

This module outputs subnet IDs and security group references for use by:
- Compute modules (EC2, ECS, EKS)
- Database modules (RDS, ElastiCache)  
- Load balancer modules (ALB, NLB)
```

### CI/CD Integration

Keep automation **simple and reliable**:

```yaml
# .github/workflows/ci.yml
name: CI

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.5.0
          
      - name: Terraform Format
        run: terraform fmt -check -recursive
        
      - name: Terraform Validate
        run: |
          terraform init
          terraform validate
          
      - name: Run Tests
        run: |
          cd test
          go test -v -timeout 30m

  release:
    if: github.ref == 'refs/heads/main'
    needs: validate
    runs-on: ubuntu-latest
    steps:
      - uses: google-github-actions/release-please-action@v4
        with:
          release-type: terraform-module
```

## AI Agent Implementation Checklist

### Module Analysis Phase
- [ ] **Identify Core Purpose**: What is the single responsibility of this module?
- [ ] **Map Dependencies**: What external resources does this module require?
- [ ] **Define Boundaries**: What should this module NOT do?
- [ ] **Consider Composition**: How will this module work with others?

### Interface Design Phase  
- [ ] **Essential Inputs Only**: Remove any variables that aren't absolutely required
- [ ] **Predictable Outputs**: Ensure outputs enable composition with other modules
- [ ] **Sensible Defaults**: Provide defaults that work for common use cases
- [ ] **Input Validation**: Add validation rules for critical inputs

### Implementation Phase
- [ ] **Single File Focus**: Keep related resources in the same file
- [ ] **Consistent Naming**: Use predictable naming patterns throughout
- [ ] **Error Handling**: Fail fast with clear error messages
- [ ] **Resource Tags**: Apply consistent tagging strategy

### Documentation Phase
- [ ] **Usage Examples**: Provide both simple and complete examples
- [ ] **Design Rationale**: Explain key design decisions
- [ ] **Composition Guide**: Show how to use with other modules
- [ ] **Generated Docs**: Run `terraform-docs` to create reference documentation

### Testing Phase
- [ ] **Plan Validation**: Ensure `terraform plan` succeeds with examples
- [ ] **Resource Verification**: Verify expected resources are planned for creation
- [ ] **Edge Case Testing**: Test with boundary conditions and invalid inputs
- [ ] **Integration Testing**: Test composition with other modules

### Deployment Readiness
- [ ] **Version Constraints**: Pin Terraform and provider versions
- [ ] **Changelog**: Document changes for each version
- [ ] **Examples Work**: Verify all examples can be deployed successfully
- [ ] **Backwards Compatibility**: Ensure changes don't break existing consumers

## Key Principles Summary

1. **One Responsibility**: Each module should do one thing well
2. **Clear Interfaces**: Make inputs and outputs predictable and minimal  
3. **Compose Don't Configure**: Design modules to work together rather than trying to handle every scenario
4. **Simple Over Easy**: Choose clarity and maintainability over convenience features
5. **Fail Fast**: Validate inputs and fail with clear messages rather than creating broken infrastructure
6. **Document Intent**: Explain design decisions, not just usage syntax

Remember: The goal is not feature completeness, but **composable simplicity**. A set of focused, well-designed modules that work together is far more valuable than a single complex module that tries to do everything.

---
Source: .ruler/terraform-style.md
---
# Terraform Style Guide for AI Agents

This guide builds upon the [Gruntwork Terraform Style Guide](https://docs.gruntwork.io/guides/style/terraform-style-guide/) and [HashiCorp's official conventions](https://developer.hashicorp.com/terraform/language/style), with emphasis on creating simple, reasoning-friendly infrastructure code.

## Core Philosophy

### Simple vs Easy
- **Simple** means "one fold" - each component has a single, clear responsibility
- **Easy** means familiar or close at hand - but familiarity doesn't guarantee maintainability
- **Choose simple over easy**: Prefer explicit, verbose code over clever shortcuts
- **Complexity is complecting**: Avoid braiding together unrelated concerns

### Reasoning-First Design
- **Code should be obvious**: A reader should be able to predict what infrastructure will be created
- **Dependencies should be explicit**: Make resource relationships clear and traceable
- **Changes should be local**: Modifications in one area shouldn't require understanding distant code

### Composition Over Configuration
- **Independent components**: Modules should work in isolation
- **Clear interfaces**: Use variables and outputs to define contracts
- **Minimal assumptions**: Don't embed knowledge about other parts of the system

## Understanding Terraform Behavior

### Mental Model
When reading Terraform code, you should be able to answer:
1. **What resources will be created?** 
2. **In what order will they be created?**
3. **What happens if this variable changes?**
4. **What external dependencies exist?**

### Dependency Reasoning
```hcl
# Good - Dependencies are explicit and traceable
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id  # Clear dependency
  cidr_block = var.private_cidr
}

# Avoid - Hidden dependencies through data sources
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]  # Implicit dependency on naming convention
  }
}
```

### Change Impact Analysis
```hcl
# Good - Changing var.environment only affects tags
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  tags          = local.common_tags
}

# Avoid - Changing var.environment affects resource names and references
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  tags = {
    Name = "${var.environment}-web-server"
  }
}
```

## Composable Design Patterns

### Module Boundaries
A module should have **one reason to change**:

```hcl
# Good - VPC module handles only networking concerns
module "vpc" {
  source = "./modules/vpc"
  
  cidr_block         = var.vpc_cidr
  availability_zones = var.availability_zones
  
  tags = local.common_tags
}

# Good - Separate module for compute concerns
module "web_servers" {
  source = "./modules/ec2-cluster"
  
  vpc_id    = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  
  instance_count = var.web_server_count
  instance_type  = var.instance_type
}
```

### Interface Design
```hcl
# Good - Clear, minimal interface
variable "vpc_config" {
  description = "VPC networking configuration"
  type = object({
    cidr_block         = string
    availability_zones = list(string)
    enable_nat_gateway = bool
  })
}

output "vpc_id" {
  description = "VPC identifier for dependent resources"
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "Private subnet IDs for compute resources"
  value       = aws_subnet.private[*].id
}
```

### Data Flow Clarity
```hcl
# Good - Data flows in one direction
locals {
  # Derived values are calculated once
  subnet_configs = {
    for az in var.availability_zones : az => {
      private_cidr = cidrsubnet(var.vpc_cidr, 8, index(var.availability_zones, az))
      public_cidr  = cidrsubnet(var.vpc_cidr, 8, index(var.availability_zones, az) + 100)
    }
  }
}

resource "aws_subnet" "private" {
  for_each = local.subnet_configs
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.private_cidr
  availability_zone = each.key
}
```

## Syntax and Style Standards

### Formatting (Enforced by `terraform fmt`)
- **2 spaces** for indentation
- **120 character** line limit
- **Blank lines** between resource blocks
- **Trailing newline** at end of file

### Naming Conventions
- **snake_case** for all identifiers: `vpc_main`, `web_server_sg`, `database_subnet_group`
- **Descriptive names**: `user_data_bucket` not `bucket1`
- **Consistent prefixes**: `aws_instance.web_server`, `aws_instance.api_server`

### Comments
```hcl
# Use # for comments, not //
# Use ---- for section delimiters

# ---------------------------------------------------------------------------------------------------------------------
# VPC CONFIGURATION
# Creates the main VPC and associated networking components
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_vpc" "main" {
  # Core VPC settings
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-vpc"
  })
}
```

### Variable Definitions
```hcl
# Always include description, type, and validation when appropriate
variable "instance_type" {
  description = "EC2 instance type for web servers"
  type        = string
  default     = "t3.micro"
  
  validation {
    condition     = contains(["t3.micro", "t3.small", "t3.medium"], var.instance_type)
    error_message = "Instance type must be t3.micro, t3.small, or t3.medium."
  }
}

# Prefer explicit object types over free-form maps
variable "database_config" {
  description = "RDS database configuration"
  type = object({
    engine         = string
    engine_version = string
    instance_class = string
    allocated_storage = number
  })
}
```

## Avoiding Complexity Traps

### 1. Implicit Dependencies
```hcl
# Trap - Resource depends on naming convention
data "aws_security_group" "web" {
  name = "${var.environment}-web-sg"  # Breaks if naming changes
}

# Better - Explicit reference
variable "web_security_group_id" {
  description = "Security group ID for web servers"
  type        = string
}
```

### 2. Conditional Complexity
```hcl
# Trap - Nested conditionals
count = var.create_database && var.environment == "prod" && length(var.subnets) > 1 ? 1 : 0

# Better - Use locals for clarity
locals {
  create_production_database = (
    var.create_database && 
    var.environment == "prod" && 
    length(var.subnets) > 1
  )
}

resource "aws_db_instance" "main" {
  count = local.create_production_database ? 1 : 0
  # ...
}
```

### 3. Hardcoded Values
```hcl
# Trap - Magic numbers and strings
resource "aws_instance" "web" {
  ami           = "ami-0abcdef1234567890"
  instance_type = "t3.micro"
  
  user_data = <<-EOF
    #!/bin/bash
    echo "Hello World" > /var/www/html/index.html
  EOF
}

# Better - Explicit configuration
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-20.04-amd64-server-*"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  user_data     = templatefile("${path.module}/user-data.sh", var.user_data_vars)
}
```

### 4. Overly Generic Modules
```hcl
# Trap - One module tries to handle everything
variable "create_vpc" { type = bool }
variable "create_subnets" { type = bool }
variable "create_nat_gateway" { type = bool }
variable "create_internet_gateway" { type = bool }
# ... 20 more boolean flags

# Better - Focused, single-purpose modules
module "vpc" {
  source = "./modules/vpc"
  # Only VPC-related configuration
}

module "subnets" {
  source = "./modules/subnets"
  vpc_id = module.vpc.vpc_id
  # Only subnet-related configuration
}
```

## AI Agent Guidelines

### Code Analysis Priority
1. **Reasoning clarity**: Can you predict what infrastructure this creates?
2. **Change impact**: Are modifications localized and predictable?
3. **Dependency clarity**: Are resource relationships explicit?
4. **Interface quality**: Are module boundaries clean and minimal?
5. **Syntax compliance**: Does it follow formatting and naming rules?

### Code Generation Principles
```hcl
# Generate code that explains itself
resource "aws_vpc" "main" {
  # VPC CIDR must not overlap with existing networks
  cidr_block = var.vpc_cidr
  
  # DNS settings required for EKS clusters
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-vpc"
  })
}
```

### When Refactoring
1. **Preserve behavior**: Ensure no unintended infrastructure changes
2. **Extract complexity**: Move complex expressions to locals with descriptive names
3. **Explicit dependencies**: Replace implicit references with explicit variable passing
4. **Simplify conditionals**: Use locals to break down complex boolean logic
5. **Add context**: Include comments explaining non-obvious decisions

### Common Refactoring Patterns
```hcl
# Before - Complex inline expression
resource "aws_subnet" "private" {
  count = var.environment == "prod" ? length(var.availability_zones) : min(2, length(var.availability_zones))
  
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index + (var.environment == "prod" ? 0 : 10))
}

# After - Clear intent with locals
locals {
  subnet_count = var.environment == "prod" ? length(var.availability_zones) : min(2, length(var.availability_zones))
  
  # Production subnets start at .0.0, non-prod at .10.0 to avoid conflicts
  cidr_offset = var.environment == "prod" ? 0 : 10
}

resource "aws_subnet" "private" {
  count = local.subnet_count
  
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + local.cidr_offset)
  availability_zone = var.availability_zones[count.index]
}
```

### Testing Guidance
Focus on **behavior verification** over syntax checking:
- Does the plan show expected resource changes?
- Are dependencies resolved in the correct order?
- Do variable changes produce predictable plan diffs?
- Can modules be composed without conflicts?

Remember: Simple is not always easy, but it is always better for long-term maintainability.

---
Source: .ruler/terraform-test.md
---
# Terraform Test Guide for AI Agents

This guide emphasizes creating simple, maintainable tests that validate essential Terraform module behavior using Terratest.

## Testing Philosophy

### What We're Actually Testing
Terraform tests validate the **contract** of your module, not AWS services:
- **Configuration validity**: Does the module accept inputs correctly?
- **Resource planning**: Does Terraform generate the expected plan?
- **Output correctness**: Do outputs match expected values?
- **Edge case handling**: How does the module behave with unusual inputs?

### Simple vs Comprehensive
- **Simple**: Tests focus on one concern and have clear pass/fail criteria
- **Comprehensive**: Tests try to cover every possible scenario and become brittle
- **Choose simple**: Write tests that are easy to understand and maintain

### Plan-Only Testing Philosophy
```go
// Good - Tests the contract without infrastructure costs
planOutput := terraform.Plan(t, terraformOptions)
assert.Contains(t, planOutput, "aws_vpc.main")

// Avoid - Tests AWS service behavior, not module logic
terraform.Apply(t, terraformOptions)
vpcId := terraform.Output(t, terraformOptions, "vpc_id")
// This tests AWS, not your module
```

## Test Design Principles

### Single Responsibility
Each test should validate **one aspect** of module behavior:

```go
// Good - Tests default behavior
func TestVPCDefaults(t *testing.T) {
    // Test that module works with minimal configuration
}

// Good - Tests feature flag
func TestVPCWithNATGateway(t *testing.T) {
    // Test that nat_gateway flag works correctly
}

// Avoid - Tests multiple unrelated features
func TestVPCEverything(t *testing.T) {
    // Tests defaults AND NAT gateway AND custom CIDR AND...
}
```

### Predictable Failure
Test failures should clearly indicate what went wrong:

```go
// Good - Clear assertion with context
assert.Contains(t, planOutput, "aws_nat_gateway.main", 
    "NAT gateway should be created when nat_gateway_enabled=true")

// Avoid - Unclear assertion
assert.NotEmpty(t, planOutput)
```

### Test Independence
Tests should not depend on each other or external state:

```go
// Good - Each test uses unique names
func TestVPCDefaults(t *testing.T) {
    uniqueName := fmt.Sprintf("test-vpc-%d", time.Now().Unix())
    terraformOptions := &terraform.Options{
        Vars: map[string]interface{}{
            "name": uniqueName,
        },
    }
}
```

### Essential vs Incidental Testing
Focus on **essential complexity** (what the module should do) rather than **incidental complexity** (implementation details):

```go
// Essential - Tests the module's contract
assert.Contains(t, planOutput, "cidr_block = \"10.0.0.0/16\"")

// Incidental - Tests implementation details
assert.Contains(t, planOutput, "depends_on = [aws_internet_gateway.main]")
```

## Repository Organization

### Structure Purpose
Each directory serves a single, clear purpose:

```
project/
├── modules/                 # The actual Terraform modules
├── examples/               # Demonstration of module usage
│   ├── defaults/          # Minimal viable configuration
│   └── complete/          # Full feature demonstration
└── test/                  # Validation of examples
    ├── go.mod
    ├── shared_test.go     # Common utilities
    ├── defaults_test.go   # Tests for defaults example
    └── complete_test.go   # Tests for complete example
```

### Example Directory Design
Each example should demonstrate **one usage pattern**:

**defaults/** - Minimal Configuration
```hcl
# Demonstrates basic functionality with sensible defaults
module "vpc" {
  source = "../../modules/vpc"
  
  name = var.name
  # All other values use module defaults
}
```

**complete/** - Full Configuration
```hcl
# Demonstrates all available options
module "vpc" {
  source = "../../modules/vpc"
  
  name                   = var.name
  cidr_block            = var.cidr_block
  enable_nat_gateway    = var.enable_nat_gateway
  availability_zones    = var.availability_zones
  # ... all other options
}
```

### Required Files Per Example
- **main.tf**: Module instantiation and providers
- **variables.tf**: Input definitions with validation
- **outputs.tf**: Output definitions (may be empty)
- **versions.tf**: Version constraints
- **terraform.auto.tfvars**: Values for required variables
- **README.md**: Usage documentation

## Implementation Patterns

### Test Structure Template
```go
func TestModuleExample(t *testing.T) {
    t.Parallel()
    
    // Generate unique test identifier
    testID := fmt.Sprintf("test-%d", time.Now().Unix())
    
    // Configure Terraform options
    terraformOptions := &terraform.Options{
        TerraformDir: "../examples/defaults",
        Vars: map[string]interface{}{
            "name": testID,
        },
        RetryableTerraformErrors: getRetryableErrors(),
        MaxRetries: 3,
        TimeBetweenRetries: 5 * time.Second,
    }
    
    // Ensure cleanup
    defer terraform.Destroy(t, terraformOptions)
    
    // Execute test
    terraform.Init(t, terraformOptions)
    planOutput := terraform.Plan(t, terraformOptions)
    
    // Validate results
	assert.NotEmpty(t, planOutput)
	// Verify invidivual resources
	assert.Contains(t, planOutput, "module.main.aws_kms_key.main[0]")
	assert.Contains(t, planOutput, "will be created")
	// Verify expected resource count
	assert.Contains(t, planOutput, "2 to add, 0 to change, 0 to destroy")
}
```

### Shared Utilities (test/shared_test.go)
```go
package test

import (
    "fmt"
    "time"
    "github.com/gruntwork-io/terratest/modules/terraform"
)

// generateTestName creates unique, AWS-compatible names
func generateTestName(prefix string) string {
    timestamp := time.Now().Unix()
    return fmt.Sprintf("%s-%d", prefix, timestamp)
}

// getBaseTerraformOptions provides common configuration
func getBaseTerraformOptions(terraformDir string) *terraform.Options {
    return &terraform.Options{
        TerraformDir:             terraformDir,
        RetryableTerraformErrors: getRetryableErrors(),
        MaxRetries:               3,
        TimeBetweenRetries:       5 * time.Second,
    }
}

// getRetryableErrors defines which errors should trigger retries
func getRetryableErrors() map[string]string {
    return map[string]string{
        // Network issues
        ".*timeout.*":                        "Network timeout",
        ".*connection reset.*":               "Connection reset",
        ".*no such host.*":                   "DNS resolution failure",
        
        // AWS throttling
        ".*Throttling.*":                     "AWS API throttling",
        ".*RequestLimitExceeded.*":           "Request limit exceeded",
        ".*TooManyRequestsException.*":       "Too many requests",
        
        // Temporary resource issues
        ".*ResourceNotReady.*":               "Resource not ready",
        ".*InvalidParameterValue.*subnet.*": "Subnet not yet available",
    }
}
```

### Test Categories

#### Configuration Validation Tests
```go
func TestValidConfiguration(t *testing.T) {
    t.Parallel()
    
    terraformOptions := getBaseTerraformOptions("../examples/defaults")
    terraformOptions.Vars = map[string]interface{}{
        "name": generateTestName("valid"),
    }
    
    defer terraform.Destroy(t, terraformOptions)
    
    terraform.Init(t, terraformOptions)
    planOutput := terraform.Plan(t, terraformOptions)
    
    // Verify plan succeeds and creates expected resources
    assert.Contains(t, planOutput, "Plan: 3 to add, 0 to change, 0 to destroy")
}
```

#### Feature Flag Tests
```go
func TestFeatureDisabled(t *testing.T) {
    t.Parallel()
    
    terraformOptions := getBaseTerraformOptions("../examples/complete")
    terraformOptions.Vars = map[string]interface{}{
        "name":                generateTestName("disabled"),
        "enable_nat_gateway": false,
    }
    
    defer terraform.Destroy(t, terraformOptions)
    
    terraform.Init(t, terraformOptions)
    planOutput := terraform.Plan(t, terraformOptions)
    
    // Verify NAT gateway is not created when disabled
    assert.NotContains(t, planOutput, "aws_nat_gateway")
}
```

#### Input Validation Tests
```go
func TestInvalidInput(t *testing.T) {
    t.Parallel()
    
    terraformOptions := getBaseTerraformOptions("../examples/defaults")
    terraformOptions.Vars = map[string]interface{}{
        "name":       generateTestName("invalid"),
        "cidr_block": "invalid-cidr", // This should cause validation failure
    }
    
    terraform.Init(t, terraformOptions)
    
    // Expect plan to fail with validation error
    _, err := terraform.PlanE(t, terraformOptions)
    assert.Error(t, err)
    assert.Contains(t, err.Error(), "invalid CIDR")
}
```

## Error Handling Strategy

### Retry Logic
Only retry **transient** errors, fail fast on **permanent** errors:

```go
// Transient - Should retry
".*Throttling.*"                    // AWS rate limiting
".*timeout.*"                       // Network issues
".*connection reset.*"              // Temporary connectivity

// Permanent - Should fail immediately  
".*InvalidParameterValue.*"         // Configuration error
".*UnauthorizedOperation.*"         // Permission issue
".*ValidationException.*"           // Input validation error
```

### Error Categories
1. **Network/Connectivity**: Temporary infrastructure issues
2. **AWS Throttling**: Rate limiting that resolves automatically
3. **Resource Dependencies**: Resources not yet available
4. **Configuration Errors**: Should fail immediately without retry

## CI/CD Integration

### Environment Setup
```yaml
# GitHub Actions example
env:
  AWS_DEFAULT_REGION: us-west-2
  TF_VAR_name_prefix: "ci-test"
  TF_VAR_environment: "ci"
```

### Test Execution
```bash
make test
```

### Cost Management
- Use plan-only testing to avoid AWS charges
- Set timeouts to prevent runaway tests
- Use unique naming to avoid resource conflicts

## AI Agent Guidelines

### Test Analysis
When examining existing tests, evaluate:

1. **Purpose Clarity**: Can you understand what each test validates?
2. **Failure Scenarios**: Will test failures clearly indicate the problem?
3. **Independence**: Can tests run in any order without conflicts?
4. **Essential Focus**: Do tests validate module contracts, not implementation details?

### Test Generation Principles

#### Start with Module Contract
```go
// Good - Tests what the module promises to do
func TestVPCCreatesSubnets(t *testing.T) {
    t.Parallel()
    
    terraformOptions := getBaseTerraformOptions("../examples/defaults")
    // ... setup
    
    planOutput := terraform.Plan(t, terraformOptions)
    
    // Verify the module creates the promised subnets
    assert.Contains(t, planOutput, "aws_subnet.private")
    assert.Contains(t, planOutput, "aws_subnet.public")
}
```

#### Test Edge Cases Systematically
```go
// Test boundary conditions
func TestVPCWithMinimalCIDR(t *testing.T) {
    // Test with /28 CIDR (smallest practical)
}

func TestVPCWithLargeCIDR(t *testing.T) {
    // Test with /16 CIDR (largest common)
}

func TestVPCWithAllAZs(t *testing.T) {
    // Test with maximum availability zones
}
```

#### Generate Meaningful Test Names
```go
// Good - Name describes the scenario and expected outcome
func TestVPCWithNATGatewayCreatesInternetAccess(t *testing.T) {}
func TestVPCWithoutNATGatewayBlocksPrivateInternet(t *testing.T) {}

// Avoid - Generic names that don't explain the test
func TestVPCNAT(t *testing.T) {}
func TestVPCComplete(t *testing.T) {}
```

### Test Maintenance
When updating tests:

1. **Preserve Intent**: Understand what the original test was validating
2. **Update Assertions**: Ensure assertions still test the right behavior  
3. **Check Dependencies**: Verify test utilities still work correctly
4. **Validate Isolation**: Ensure tests don't interfere with each other

### Debugging Test Failures
Systematic approach to test failures:

1. **Read the Error**: What specific assertion failed?
2. **Check the Plan**: What did Terraform actually try to create?
3. **Verify Inputs**: Are test variables correct?
4. **Isolate the Issue**: Can you reproduce with `terraform plan` manually?
5. **Check Dependencies**: Are required resources/permissions available?

### Common Anti-Patterns to Avoid

#### Over-Testing
```go
// Avoid - Testing every possible input combination
func TestAllPossibleConfigurations(t *testing.T) {
    // This becomes unwieldy and doesn't add value
}

// Better - Test representative scenarios
func TestCommonConfigurations(t *testing.T) {
    // Test the most important use cases
}
```

#### Implementation Testing
```go
// Avoid - Testing Terraform internals
assert.Contains(t, planOutput, "depends_on")

// Better - Testing module behavior
assert.Contains(t, planOutput, "aws_vpc.main")
```

#### Complex Test Logic
```go
// Avoid - Tests that are hard to understand
func TestComplexScenario(t *testing.T) {
    if condition1 && condition2 {
        // Test scenario A
    } else if condition3 {
        // Test scenario B  
    } else {
        // Test scenario C
    }
}

// Better - Separate tests for each scenario
func TestScenarioA(t *testing.T) { /* Clear test logic */ }
func TestScenarioB(t *testing.T) { /* Clear test logic */ }
func TestScenarioC(t *testing.T) { /* Clear test logic */ }
```

## Key Takeaways

1. **Test the Contract**: Focus on what your module promises to do
2. **Keep It Simple**: Each test should have a single, clear purpose
3. **Make Failures Clear**: Test failures should immediately indicate the problem
4. **Plan-Only When Possible**: Avoid unnecessary AWS costs and complexity
5. **Design for Independence**: Tests should not depend on each other
6. **Focus on Essential Behavior**: Test what matters, not implementation details

Remember: The goal is not comprehensive coverage, but confidence in essential functionality.
