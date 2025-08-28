# Primary context - creates the base context with initial values
module "primary_context" {
  source = "../../"

  namespace        = var.namespace
  name             = var.name
  environment      = "qapr"
  environment_name = "QA Primary"

  # Set some additional context values to demonstrate inheritance
  cloud_provider   = "aws"
  environment_type = "Testing"
  cost_center      = "engineering"
  product_owners   = ["team-platform"]
  code_owners      = ["platform-team"]
  data_owners      = ["data-team"]
  availability     = "always_on"
  sensitivity      = "confidential"
  data_regs        = ["gdpr", "ccpa"]
  security_review  = "passed"
  privacy_review   = "passed"

  additional_tags = {
    Project = "context-demo"
    Purpose = "primary-environment"
  }

  additional_data_tags = {
    DataClassification = "restricted"
    RetentionPeriod    = "7-years"
  }
}

# Failover context - inherits from primary context but overrides environment settings
module "failover_context" {
  source = "../../"

  # Pass the entire context from the primary module
  context = module.primary_context.context

  # Override only the environment-specific settings
  environment      = "qafo"
  environment_name = "QA Failover"

  # Override some tags to show this is the failover environment
  additional_tags = {
    Project = "context-demo"
    Purpose = "failover-environment"
  }

  additional_data_tags = {
    DataClassification = "restricted"
    RetentionPeriod    = "7-years"
    FailoverPrimary    = module.primary_context.name_prefix
  }
}
