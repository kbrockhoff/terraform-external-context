enabled          = true
environment_type = "None"

# Core identification
cloud_provider    = "aws"
namespace         = "ck"
name              = "complete"
environment       = "dev"
environment_name  = "Development"
tag_prefix        = "ck-"
pm_platform       = "JIRA"
pm_project_code   = "TF"
itsm_platform     = "SNOW"
itsm_system_id    = "BA12345"
itsm_component_id = "AS123456"
itsm_instance_id  = "use1"

# Ownership and governance
cost_center    = "12345"
product_owners = ["finance@example.com"]
code_owners    = ["devops@example.com", "platform@example.com"]
data_owners    = ["data-governance@example.com"]

# Operational settings
availability    = "business_hours"
managedby       = "terraform-complete-example"
deletion_date   = null
sensitivity     = "confidential"
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

source_repo_tags_enabled = true