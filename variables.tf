variable "availability_values" {
  description = "List of allowed availability values"
  type        = list(string)
  default     = ["always_on", "business_hours", "preemptable"]
}

variable "sensitivity_values" {
  description = "List of allowed sensitivity values for data classification"
  type        = list(string)
  default     = ["public", "internal", "trusted-3rd-party", "confidential", "highly-confidential", "client-classified"]
}

variable "context" {
  description = <<-EOT
    Single object for setting entire context at once.
    See description of individual variables for details.
    Leave string and numeric variables as `null` to use default value.
    Individual variable settings (non-null) override settings in context object,
    except for additional_tags and additional_data_tags which are merged.
  EOT
  type        = any
  default = {
    enabled                  = true
    environment_type         = "Development"
    cloud_provider           = "dc"
    namespace                = null
    name                     = null
    environment              = null
    environment_name         = null
    tag_prefix               = "bc-"
    pm_platform              = null
    pm_project_code          = null
    itsm_platform            = null
    itsm_system_id           = null
    itsm_component_id        = null
    itsm_instance_id         = null
    cost_center              = null
    product_owners           = []
    code_owners              = []
    data_owners              = []
    availability             = "preemptable"
    availability_values      = ["always_on", "business_hours", "preemptable"]
    managedby                = "Terraform"
    deletion_date            = null
    sensitivity              = "confidential"
    sensitivity_values       = ["public", "internal", "trusted-3rd-party", "confidential", "highly-confidential", "client-classified"]
    data_regs                = []
    security_review          = null
    privacy_review           = null
    additional_tags          = {}
    additional_data_tags     = {}
    source_repo_tags_enabled = true
    system_prefixes_enabled  = true
    not_applicable_enabled   = true
    owner_tags_enabled       = true
  }

  validation {
    condition     = contains(["dc", "aws", "az", "gcp", "oci", "ibm", "do", "vul", "ali", "cv"], var.context.cloud_provider)
    error_message = "Allowed values: `dc`, `aws`, `az`, `gcp`, `oci`, `ibm`, `do`, `vul`, `ali`, `cv`."
  }

  validation {
    condition = contains([
      "None", "Ephemeral", "Development", "Testing", "UAT", "Production", "MissionCritical"
    ], var.context.environment_type)
    error_message = "Environment type must be one of: None, Ephemeral, Development, Testing, UAT, Production, MissionCritical."
  }

  validation {
    condition     = var.context.namespace == null ? true : can(regex("^[a-z][a-z0-9-]{0,6}[a-z0-9]?$", var.context.namespace))
    error_message = "Must be between 1 and 8 characters in length."
  }

  validation {
    condition = var.context.name == null ? true : (
      var.context.namespace == null || var.context.environment == null ? (
        can(regex("^[a-z][a-z0-9-]{0,22}[a-z0-9]$", var.context.name))
        ) : (
        can(regex("^[a-z][a-z0-9-]{0,22}[a-z0-9]$", lower(join("-", [var.context.namespace, var.context.name, var.context.environment]))))
      )
    )
    error_message = "The resulting name_prefix must match pattern /^[a-z][a-z0-9-]{0,22}[a-z0-9]$/. Must be 2-24 characters total, start with lowercase letter, contain only lowercase letters, numbers, and hyphens, and end with alphanumeric character."
  }

  validation {
    condition     = var.context.environment == null ? true : can(regex("^[a-z][a-z0-9-]{0,6}[a-z0-9]?$", var.context.environment))
    error_message = "Must be between 1 and 8 characters in length."
  }

  validation {
    condition = var.context.availability == null ? (
      true
      ) : (
      contains(var.availability_values, var.context.availability)
    )
    error_message = "Allowed values: ${join(", ", [for v in var.availability_values : "`${v}`"])}."
  }

  validation {
    condition = var.context.sensitivity == null ? (
      true
      ) : (
      contains(var.sensitivity_values, var.context.sensitivity)
    )
    error_message = "Allowed values: ${join(", ", [for v in var.sensitivity_values : "`${v}`"])}."
  }
}

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
    condition = var.name == null ? true : (
      var.namespace == null || var.environment == null ? (
        can(regex("^[a-z][a-z0-9-]{0,22}[a-z0-9]$", var.name))
        ) : (
        can(regex("^[a-z][a-z0-9-]{0,22}[a-z0-9]$", lower(join("-", [var.namespace, var.name, var.environment]))))
      )
    )
    error_message = "The resulting name_prefix must match pattern /^[a-z][a-z0-9-]{0,22}[a-z0-9]$/. Must be 2-24 characters total, start with lowercase letter, contain only lowercase letters, numbers, and hyphens, and end with alphanumeric character."
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

variable "tag_prefix" {
  description = "Prefix for standardized tags"
  type        = string
  default     = "bc-"
}

variable "pm_platform" {
  description = "System for project management ticketing (i.e. JIRA, SNOW)."
  type        = string
  default     = null
}

variable "pm_project_code" {
  description = "The prefix used on your project management platform tickets."
  type        = string
  default     = null
}

variable "cost_center" {
  description = "Cost center this resource should be billed to."
  type        = string
  default     = null
}


variable "product_owners" {
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
      contains(var.availability_values, var.availability)
    )
    error_message = "Allowed values: ${join(", ", [for v in var.availability_values : "`${v}`"])}."
  }
}

variable "managedby" {
  description = "ID of the CI/CD platform or person who last updated the resource."
  type        = string
  default     = null
}

variable "deletion_date" {
  description = "Date resource should be deleted if still running."
  type        = string
  default     = null
}

variable "sensitivity" {
  description = "Standard name from enumerated list for data sensitivity. (public, internal, trusted-3rd-party, confidential, highly-confidential, client-classified)"
  type        = string
  default     = null

  validation {
    condition = var.sensitivity == null ? (
      true
      ) : (
      contains(var.sensitivity_values, var.sensitivity)
    )
    error_message = "Allowed values: ${join(", ", [for v in var.sensitivity_values : "`${v}`"])}."
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
  description = "Additional tags (e.g. `map('BusinessUnit','XYZ')`)"
  type        = map(string)
  default     = {}
}

variable "additional_data_tags" {
  description = "Additional data tags for resources with data at rest (e.g. `map('DataClassification','Confidential')`)"
  type        = map(string)
  default     = {}
}

variable "source_repo_tags_enabled" {
  description = "Enable source repository tags"
  type        = bool
  default     = true
}

variable "system_prefixes_enabled" {
  description = "Enable system prefixes in project management and ITSM tags"
  type        = bool
  default     = true
}

variable "not_applicable_enabled" {
  description = "Enable N/A tags for null values (when false, omit tags with null values)"
  type        = bool
  default     = true
}

variable "owner_tags_enabled" {
  description = "Enable owner tags (productowners, codeowners, dataowners)"
  type        = bool
  default     = true
}

variable "itsm_platform" {
  description = "IT Service Management platform (e.g., ServiceNow, JIRA Service Management)"
  type        = string
  default     = null
}

variable "itsm_system_id" {
  description = "ITSM system identifier ID"
  type        = string
  default     = null
}

variable "itsm_component_id" {
  description = "ITSM component identifier ID"
  type        = string
  default     = null
}

variable "itsm_instance_id" {
  description = "ITSM instance identifier ID"
  type        = string
  default     = null
}
