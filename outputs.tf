# ----
# Primary resources IDs and names
# ----

# ----
# Encryption
# ----

output "kms_key_id" {
  description = "ID of the KMS key used for encryption"
  value       = var.enabled && var.create_kms_key ? aws_kms_key.main[0].key_id : ""
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for encryption"
  value       = local.kms_key_id
}

output "kms_alias_name" {
  description = "Name of the KMS key alias"
  value       = var.enabled && var.create_kms_key ? aws_kms_alias.main[0].name : ""
}

# ----
# Monitoring
# ----

output "alarm_sns_topic_arn" {
  description = "ARN of the SNS topic used for alarm notifications"
  value       = local.alarm_sns_topic_arn
}

output "alarm_sns_topic_name" {
  description = "Name of the SNS topic used for alarm notifications"
  value       = var.enabled && local.effective_config.alarms_enabled && var.create_alarm_sns_topic ? aws_sns_topic.alarms[0].name : ""
}

# ----
# Pricing
# ----

output "monthly_cost_estimate" {
  description = "Estimated monthly cost in USD for module resources"
  value       = module.pricing.monthly_cost_estimate
}

output "cost_breakdown" {
  description = "Detailed breakdown of monthly costs by service"
  value       = module.pricing.cost_breakdown
}
