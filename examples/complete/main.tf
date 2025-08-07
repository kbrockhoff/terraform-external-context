# Main AWS provider - uses the current region
provider "aws" {
  # This is the default provider used for VPC resources
}

# Pricing provider - always uses us-east-1 where the AWS Pricing API is available
provider "aws" {
  alias  = "pricing"
  region = "us-east-1"
}

module "main" {
  source = "../../"

  enabled              = var.enabled
  environment_type     = var.environment_type
  cloud_provider       = var.cloud_provider
  namespace            = var.namespace
  name                 = var.name
  environment          = var.environment
  environment_name     = var.environment_name
  cost_center          = var.cost_center
  project              = var.project
  project_owners       = var.project_owners
  code_owners          = var.code_owners
  data_owners          = var.data_owners
  availability         = var.availability
  deployer             = var.deployer
  deletion_date        = var.deletion_date
  confidentiality      = var.confidentiality
  data_regs            = var.data_regs
  security_review      = var.security_review
  privacy_review       = var.privacy_review
  additional_tags      = var.additional_tags
  additional_data_tags = var.additional_data_tags
}
