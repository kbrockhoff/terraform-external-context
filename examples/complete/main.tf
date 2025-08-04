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

  providers = {
    aws         = aws
    aws.pricing = aws.pricing
  }

  enabled                      = var.enabled
  name_prefix                  = var.name_prefix
  tags                         = var.tags
  data_tags                    = var.data_tags
  environment_type             = var.environment_type
  cost_estimation_enabled      = var.cost_estimation_enabled
  networktags_name             = var.networktags_name
  create_kms_key               = var.create_kms_key
  kms_key_id                   = var.kms_key_id
  kms_key_deletion_window_days = var.kms_key_deletion_window_days
  monitoring_enabled           = var.monitoring_enabled
  alarms_enabled               = var.alarms_enabled
  create_alarm_sns_topic       = var.create_alarm_sns_topic
  alarm_sns_topic_arn          = var.alarm_sns_topic_arn
}
