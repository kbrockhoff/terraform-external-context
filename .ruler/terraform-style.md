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
