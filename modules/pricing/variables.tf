variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  type        = bool
  default     = true
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "create_kms_key" {
  description = "Whether to create a KMS key for encryption"
  type        = bool
  default     = false
}
