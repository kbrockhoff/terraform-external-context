variable "name" {
  description = "Unique name within that particular hierarchy level and resource type."
  type        = string
  default     = null

  validation {
    condition     = var.name == null ? true : length(trimspace(var.name)) >= 2
    error_message = "At least 2 characters in length required."
  }
}
