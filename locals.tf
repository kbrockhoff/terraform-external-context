locals {
  # Environment type configuration maps
  environment_defaults = {
    None = {
      rpo_hours                    = null
      rto_hours                    = null
      monitoring_enabled           = var.monitoring_enabled
      alarms_enabled               = var.alarms_enabled
      kms_key_deletion_window_days = var.kms_key_deletion_window_days
    }
    Ephemeral = {
      rpo_hours                    = null
      rto_hours                    = 48
      monitoring_enabled           = false
      alarms_enabled               = false
      kms_key_deletion_window_days = 7 # Minimal window for ephemeral environments
    }
    Development = {
      rpo_hours                    = 24
      rto_hours                    = 48
      monitoring_enabled           = false
      alarms_enabled               = false
      kms_key_deletion_window_days = 7 # Short window for development
    }
    Testing = {
      rpo_hours                    = 24
      rto_hours                    = 48
      monitoring_enabled           = false
      alarms_enabled               = false
      kms_key_deletion_window_days = 14 # Medium window for testing
    }
    UAT = {
      rpo_hours                    = 12
      rto_hours                    = 24
      monitoring_enabled           = false
      alarms_enabled               = false
      kms_key_deletion_window_days = 14 # Medium window for UAT
    }
    Production = {
      rpo_hours                    = 1
      rto_hours                    = 4
      monitoring_enabled           = true
      alarms_enabled               = true
      kms_key_deletion_window_days = 30 # Maximum window for production
    }
    MissionCritical = {
      rpo_hours                    = 0.083 # 5 minutes
      rto_hours                    = 1
      monitoring_enabled           = true
      alarms_enabled               = true
      kms_key_deletion_window_days = 30 # Maximum window for mission critical
    }
  }

  # Apply environment defaults when environment_type is not "None"
  effective_config = var.environment_type == "None" ? (
    local.environment_defaults.None
    ) : (
    local.environment_defaults[var.environment_type]
  )

  # AWS account, partition, and region info
  account_id         = data.aws_caller_identity.current.account_id
  partition          = data.aws_partition.current.partition
  region             = data.aws_region.current.region
  dns_suffix         = data.aws_partition.current.dns_suffix
  reverse_dns_prefix = data.aws_partition.current.reverse_dns_prefix

  common_tags = merge(var.tags, {
    ModuleName    = "kbrockhoff/replace-me/provider"
    ModuleVersion = local.module_version
    ModuleEnvType = var.environment_type
  })
  common_data_tags = merge(var.data_tags, local.common_tags)

  name_prefix = var.name_prefix

  # KMS key logic - use provided key ID or create new one
  kms_key_id = var.enabled ? (
    var.create_kms_key ? aws_kms_key.main[0].arn : var.kms_key_id
  ) : ""

  # SNS topic logic - use provided topic ARN or create new one
  create_sns_topic = var.enabled && local.effective_config.alarms_enabled && var.create_alarm_sns_topic
  alarm_sns_topic_arn = var.enabled && local.effective_config.alarms_enabled ? (
    var.create_alarm_sns_topic ? aws_sns_topic.alarms[0].arn : var.alarm_sns_topic_arn
  ) : ""

}
