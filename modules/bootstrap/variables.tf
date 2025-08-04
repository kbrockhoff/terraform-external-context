variable "enabled" {
  description = "Set to false to prevent the module from creating any resources."
  type        = bool
  default     = true
}

variable "name_prefix" {
  description = "Organization unique prefix to use for resource names. Recommend including environment and region. e.g. 'prod-usw2'."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,15}$", var.name_prefix))
    error_message = "The name_prefix value must be between 2 and 16 characters."
  }
}

variable "github_org" {
  description = "GitHub organization name"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "environment" {
  description = "Environment name for OIDC trust (e.g., 'development', 'staging', 'production')"
  type        = string
  default     = "*"
}

variable "tags" {
  description = "Tags/labels to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "partition" {
  description = "AWS partition"
  type        = string
  default     = "aws"
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "s3_backend_bucket" {
  description = "S3 bucket name for Terraform state backend"
  type        = string
}

variable "s3_backend_lock_table" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
}
