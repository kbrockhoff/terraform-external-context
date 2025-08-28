variable "namespace" {
  description = "Namespace identifier"
  type        = string
  default     = "ck"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,23}$", var.namespace))
    error_message = "Namespace must be 2-24 characters, lowercase, start with letter."
  }
}

variable "name" {
  description = "Name identifier for the application"
  type        = string
  default     = "multi"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,23}$", var.name))
    error_message = "Name must be 2-24 characters, lowercase, start with letter."
  }
}
