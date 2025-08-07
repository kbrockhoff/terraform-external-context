variable "enabled" {
  description = "Set to false to prevent the module from creating any resources."
  type        = bool
  default     = null
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

variable "cloud_provider" {
  description = "Public/private cloud provider [dc, aws, az, gcp, oci, ibm, do, vul, ali, cv]."
  type        = string
  default     = null

  validation {
    condition = var.cloud_provider == null ? (
      true
      ) : (
      contains(["dc", "aws", "az", "gcp", "oci", "ibm", "do", "vul", "ali", "cv"], var.cloud_provider)
    )
    error_message = "Allowed values: `dc`, `aws`, `az`, `gcp`, `oci`, `ibm`, `do`, `vul`, `ali`, `cv`."
  }
}

variable "namespace" {
  description = "Namespace which could be an organization, business unit, or other grouping."
  type        = string
  default     = null

  validation {
    condition     = var.namespace == null ? true : can(regex("^[a-z][a-z0-9-]{0,6}[a-z0-9]?$", var.namespace))
    error_message = "Must be between 1 and 8 characters in length."
  }
}

variable "name" {
  description = "Unique name within that particular hierarchy level and resource type."
  type        = string
  default     = null

  validation {
    condition     = var.name == null ? true : can(regex("^[a-z][a-z0-9-]{0,14}[a-z0-9]$", var.name))
    error_message = "The name value must start with a lowercase letter, followed by 1 to 15 alphanumeric or hyphen characters, for a total length of 2 to 16 characters."
  }
}

variable "environment" {
  description = "Abbreviation for the deployment environment. i.e. [sbox, dev, test, qa, uat, prod, prd-use1, prd-usw2, dr]"
  type        = string
  default     = null

  validation {
    condition     = var.environment == null ? true : can(regex("^[a-z][a-z0-9-]{0,6}[a-z0-9]?$", var.environment))
    error_message = "Must be between 1 and 8 characters in length."
  }
}

variable "environment_name" {
  description = "Full name for the deployment environment (can be more descriptive than the standard environment)."
  type        = string
  default     = null
}

variable "cost_center" {
  description = "Cost center this resource should be billed to."
  type        = string
  default     = null
}

variable "project" {
  description = "Identifier for the product or project which created or owns this resource."
  type        = string
  default     = null
}

variable "project_owners" {
  description = "List of email addresses to contact with billing questions."
  type        = list(string)
  default     = null
}

variable "code_owners" {
  description = "List of email addresses to contact for application issue resolution."
  type        = list(string)
  default     = null
}

variable "data_owners" {
  description = "List of email addresses to contact for data governance issues."
  type        = list(string)
  default     = null
}

variable "availability" {
  description = "Standard name from enumerated list of availability requirements. (always_on, business_hours, preemptable)"
  type        = string
  default     = null

  validation {
    condition = var.availability == null ? (
      true
      ) : (
      contains(["always_on", "business_hours", "preemptable"], var.availability)
    )
    error_message = "Allowed values: `always_on`, `business_hours`, `preemptable`."
  }
}

variable "deployer" {
  description = "ID of the CI/CD platform or person who last updated the resource."
  type        = string
  default     = null
}

variable "deletion_date" {
  description = "Date resource should be deleted if still running."
  type        = string
  default     = null
}

variable "confidentiality" {
  description = "Standard name from enumerated list for data confidentiality. (public, confidential, client, private)"
  type        = string
  default     = null

  validation {
    condition = var.confidentiality == null ? (
      true
      ) : (
      contains(["public", "confidential", "client", "private"], var.confidentiality)
    )
    error_message = "Allowed values: `public`, `confidential`, `client`, `private`."
  }
}

variable "data_regs" {
  description = "List of regulations which resource data must comply with."
  type        = list(string)
  default     = null
}

variable "security_review" {
  description = "ID or date of last security review or audit"
  type        = string
  default     = null
}

variable "privacy_review" {
  description = "ID or date of last data privacy review or audit."
  type        = string
  default     = null
}

variable "additional_tags" {
  description = "Additional tags (e.g. `map('BusinessUnit','XYZ')`"
  type        = map(string)
  default     = {}
}

variable "additional_data_tags" {
  description = "Additional data tags for resources with data at rest (e.g. `map('DataClassification','Confidential')`"
  type        = map(string)
  default     = {}
}