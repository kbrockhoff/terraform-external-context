variable "namespace" {
  description = "Namespace identifier"
  type        = string
  default     = "ck"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,15}$", var.namespace))
    error_message = "Namespace must be 2-16 characters, lowercase, start with letter."
  }
}

variable "name" {
  description = "Name identifier for the application"
  type        = string
  default     = "multi"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,15}$", var.name))
    error_message = "Name must be 2-16 characters, lowercase, start with letter."
  }
}

variable "environment" {
  description = "Environment identifier (e.g., dev, qaprim, qafo, prod)"
  type        = string
  default     = "qaprim"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,15}$", var.environment))
    error_message = "Environment must be 2-16 characters, lowercase, start with letter."
  }
}

variable "environment_name" {
  description = "Human-readable environment name"
  type        = string
  default     = "QA Primary"
}
