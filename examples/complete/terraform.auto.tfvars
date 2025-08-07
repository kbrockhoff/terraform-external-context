enabled          = true
environment_type = "None"

# Core identification
cloud_provider   = "aws"
namespace        = "ck"
name             = "complete"
environment      = "dev"
environment_name = "Development"

# Ownership and governance
cost_center    = "12345"
project        = "terraform-context"
project_owners = ["finance@example.com"]
code_owners    = ["devops@example.com", "platform@example.com"]
data_owners    = ["data-governance@example.com"]

# Operational settings
availability    = "business_hours"
deployer        = "terraform-complete-example"
deletion_date   = null
confidentiality = "confidential"
data_regs       = ["GDPR", "SOX"]
security_review = "2024-01-15"
privacy_review  = "2024-01-15"

# Additional tags
additional_tags = {
  "Environment" = "Development"
  "Example"     = "complete"
  "Team"        = "Platform"
}

additional_data_tags = {
  "DataClassification" = "Confidential"
  "RetentionPeriod"    = "7years"
}
