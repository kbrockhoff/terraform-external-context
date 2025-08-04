# ----
# Common
# ----

variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  type        = bool
  default     = true
}

variable "name_prefix" {
  description = "Organization unique prefix to use for resource names. Recommend including environment and region. e.g. 'prod-usw2'"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,15}$", var.name_prefix))
    error_message = "The name_prefix value must start with a lowercase letter, followed by 1 to 15 alphanumeric or hyphen characters, for a total length of 2 to 16 characters."
  }
}

variable "tags" {
  description = "Tags/labels to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "data_tags" {
  description = "Tags/labels to apply to all resources with data-at-rest"
  type        = map(string)
  default     = {}
}

variable "environment_type" {
  description = "Environment type for resource configuration defaults. Select 'None' to use individual config values."
  type        = string
  default     = "Development"

  validation {
    condition = contains([
      "None", "Ephemeral", "Development", "Testing", "UAT", "Production", "MissionCritical"
    ], var.environment_type)
    error_message = "Environment type must be one of: None, Ephemeral, Development, Testing, UAT, Production, MissionCritical."
  }
}

variable "cost_estimation_enabled" {
  description = "Set to false to disable estimation of monthly costs for provisioned resources"
  type        = bool
  default     = true
}

variable "networktags_name" {
  description = "Name of the network tags key used for subnet classification"
  type        = string
  default     = "NetworkTags"

  validation {
    condition     = var.networktags_name != null && var.networktags_name != ""
    error_message = "Network tags name cannot be null or blank."
  }
}

# ----
# Encryption
# ----

variable "create_kms_key" {
  description = "Set to true to create a customer-managed KMS key for encryption. Set to false to use an existing key specified in kms_key_id."
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "ARN or ID of existing KMS key to use for encryption. Only used when create_kms_key is false."
  type        = string
  default     = ""

  validation {
    condition     = (var.create_kms_key && var.kms_key_id == "") || (!var.create_kms_key && var.kms_key_id != "")
    error_message = "kms_key_id must be empty when create_kms_key is true, or provided when create_kms_key is false."
  }
}

variable "kms_key_deletion_window_days" {
  description = "Number of days to wait before deleting KMS key when destroyed. Only used when create_kms_key is true."
  type        = number
  default     = 14

  validation {
    condition     = var.kms_key_deletion_window_days >= 7 && var.kms_key_deletion_window_days <= 30
    error_message = "KMS key deletion window must be between 7 and 30 days when specified."
  }
}

# ----
# Monitoring
# ----

variable "monitoring_enabled" {
  description = "Launched EC2 instance will have detailed monitoring enabled."
  type        = bool
  default     = false
}

variable "alarms_enabled" {
  description = "Enable CloudWatch alarms for monitoring autoscaling group health"
  type        = bool
  default     = false
}

variable "create_alarm_sns_topic" {
  description = "Set to true to create an SNS topic for alarm notifications. Set to false to use an existing topic specified in alarm_sns_topic_arn."
  type        = bool
  default     = true
}

variable "alarm_sns_topic_arn" {
  description = "ARN of existing SNS topic to use for alarm notifications. Only used when create_alarm_sns_topic is false."
  type        = string
  default     = ""

  validation {
    condition     = (var.create_alarm_sns_topic && var.alarm_sns_topic_arn == "") || (!var.create_alarm_sns_topic && var.alarm_sns_topic_arn != "")
    error_message = "alarm_sns_topic_arn must be empty when create_alarm_sns_topic is true, or provided when create_alarm_sns_topic is false."
  }
}
