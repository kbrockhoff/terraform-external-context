locals {
  default_constraints = {
    tag_lowercase     = false
    tag_replace_chars = "/[<>%&\\?]/"
    tag_replacement   = "_"
    tag_delimiter     = ";"
    tag_length_limit  = 63
    not_applicable    = "N/A"
  }
  cp_constraints_map = {
    aws = {
      tag_lowercase     = false
      tag_replace_chars = "/[^a-zA-Z0-9 \\.:=+@_/-]/"
      tag_replacement   = "_"
      tag_delimiter     = " "
      tag_length_limit  = 256
      not_applicable    = "N/A"
    }
    az = {
      tag_lowercase     = false
      tag_replace_chars = "/[ <>%&\\?/#:]/"
      tag_replacement   = ""
      tag_delimiter     = ";"
      tag_length_limit  = 256
      not_applicable    = "NotApplicable"
    }
    gcp = {
      tag_lowercase     = true
      tag_replace_chars = "/[^a-z0-9_-]/"
      tag_replacement   = "-"
      tag_delimiter     = "_"
      tag_length_limit  = 63
      not_applicable    = "not_applicable"
    }
  }

  # Merging of inputs from parent context, if supplied, and this context's overrides
  input = {
    enabled                  = var.enabled == null ? var.context.enabled : var.enabled
    environment_type         = var.environment_type == null ? var.context.environment_type : var.environment_type
    cloud_provider           = var.cloud_provider == null ? var.context.cloud_provider : var.cloud_provider
    namespace                = var.namespace == null ? var.context.namespace : var.namespace
    name                     = var.name == null ? var.context.name : var.name
    environment              = var.environment == null ? var.context.environment : var.environment
    environment_name         = var.environment_name == null ? var.context.environment_name : var.environment_name
    tag_prefix               = var.tag_prefix == null ? var.context.tag_prefix : var.tag_prefix
    pm_platform              = var.pm_platform == null ? var.context.pm_platform : var.pm_platform
    pm_project_code          = var.pm_project_code == null ? var.context.pm_project_code : var.pm_project_code
    itsm_platform            = var.itsm_platform == null ? var.context.itsm_platform : var.itsm_platform
    itsm_system_id           = var.itsm_system_id == null ? var.context.itsm_system_id : var.itsm_system_id
    itsm_component_id        = var.itsm_component_id == null ? var.context.itsm_component_id : var.itsm_component_id
    itsm_instance_id         = var.itsm_instance_id == null ? var.context.itsm_instance_id : var.itsm_instance_id
    cost_center              = var.cost_center == null ? var.context.cost_center : var.cost_center
    product_owners           = var.product_owners == null ? var.context.product_owners : var.product_owners
    code_owners              = var.code_owners == null ? var.context.code_owners : var.code_owners
    data_owners              = var.data_owners == null ? var.context.data_owners : var.data_owners
    availability             = var.availability == null ? var.context.availability : var.availability
    availability_values      = var.availability_values
    managedby                = var.managedby == null ? var.context.managedby : var.managedby
    deletion_date            = var.deletion_date == null ? var.context.deletion_date : var.deletion_date
    sensitivity              = var.sensitivity == null ? var.context.sensitivity : var.sensitivity
    sensitivity_values       = var.sensitivity_values
    data_regs                = var.data_regs == null ? var.context.data_regs : var.data_regs
    security_review          = var.security_review == null ? var.context.security_review : var.security_review
    privacy_review           = var.privacy_review == null ? var.context.privacy_review : var.privacy_review
    additional_tags          = merge(var.context.additional_tags, var.additional_tags)
    additional_data_tags     = merge(var.context.additional_data_tags, var.additional_data_tags)
    source_repo_tags_enabled = var.source_repo_tags_enabled == null ? var.context.source_repo_tags_enabled : var.source_repo_tags_enabled
    system_prefixes_enabled  = var.system_prefixes_enabled == null ? var.context.system_prefixes_enabled : var.system_prefixes_enabled
    not_applicable_enabled   = var.not_applicable_enabled == null ? var.context.not_applicable_enabled : var.not_applicable_enabled
    owner_tags_enabled       = var.owner_tags_enabled == null ? var.context.owner_tags_enabled : var.owner_tags_enabled
  }

  cstr = merge(local.default_constraints, lookup(local.cp_constraints_map, local.input.cloud_provider, {}))

  env          = local.input.environment == null ? "dev" : local.input.environment
  env_name     = local.input.environment_name == null ? local.env : local.input.environment_name
  enabled      = local.input.enabled == null ? true : local.input.enabled
  tag_prefix   = local.input.tag_prefix == null ? "" : local.input.tag_prefix
  availability = local.input.availability == null ? "preemptable" : local.input.availability
  sensitivity  = local.input.sensitivity == null ? "confidential" : local.input.sensitivity
  managedby    = local.input.managedby == null ? "terraform" : local.input.managedby

  # Combine PM platform and project code
  pm_info = local.input.pm_project_code == null ? null : (
    join(local.cstr["tag_delimiter"], compact([
      local.input.system_prefixes_enabled && local.input.pm_platform != null ? local.input.pm_platform : null,
      local.input.pm_project_code
    ]))
  )

  # Individual ITSM IDs with optional platform prefix
  itsm_system_id = local.input.itsm_system_id == null ? null : (
    local.input.system_prefixes_enabled && local.input.itsm_platform != null ? (
      join(local.cstr["tag_delimiter"], [local.input.itsm_platform, local.input.itsm_system_id])
    ) : local.input.itsm_system_id
  )
  itsm_component_id = local.input.itsm_component_id == null ? null : (
    local.input.system_prefixes_enabled && local.input.itsm_platform != null ? (
      join(local.cstr["tag_delimiter"], [local.input.itsm_platform, local.input.itsm_component_id])
    ) : local.input.itsm_component_id
  )
  itsm_instance_id = local.input.itsm_instance_id == null ? null : (
    local.input.system_prefixes_enabled && local.input.itsm_platform != null ? (
      join(local.cstr["tag_delimiter"], [local.input.itsm_platform, local.input.itsm_instance_id])
    ) : local.input.itsm_instance_id
  )

  # Source repository URL processing
  source_repo_raw = local.input.source_repo_tags_enabled ? try(trimsuffix(data.external.git_repo[0].result["url"], ".git"), "") : ""
  source_repo = local.input.source_repo_tags_enabled ? (
    startswith(local.source_repo_raw, "git@") ? (
      replace(replace(local.source_repo_raw, ":", "/"), "git@", "https://")
      ) : (
      local.source_repo_raw
    )
  ) : ""

  # Source repository commit hash
  source_commit = local.input.source_repo_tags_enabled ? try(data.external.git_repo[0].result["commit"], "") : ""

  # Name prefix generation logic following Brockhoff standards
  # Rule 1: If namespace, name, and environment are provided, join with hyphens in order: namespace-name-environment
  # Rule 2: If only name is provided (namespace and environment are null/empty), use name only
  # Rule 3: If the combined prefix exceeds 24 characters, truncate the name component to fit

  # Calculate raw name prefix first
  raw_name_prefix = local.input.namespace == null || local.input.environment == null ? (
    local.input.name
    ) : (
    lower(join("-", [local.input.namespace, local.input.name, local.input.environment]))
  )

  # Helper calculations for name truncation
  namespace_len      = local.input.namespace != null ? length(local.input.namespace) : 0
  environment_len    = local.input.environment != null ? length(local.input.environment) : 0
  available_name_len = 24 - local.namespace_len - local.environment_len - 2
  truncated_name_len = max(1, local.available_name_len)
  truncated_name     = substr(local.input.name, 0, local.truncated_name_len)

  # Truncate if necessary to fit within 24 character limit
  name_prefix = length(local.raw_name_prefix) <= 24 ? local.raw_name_prefix : (
    local.input.namespace == null || local.input.environment == null ? (
      # If no namespace/environment, truncate name to 24 chars
      substr(local.input.name, 0, 24)
      ) : (
      # Use calculated values to create truncated prefix
      lower(join("-", [local.input.namespace, local.truncated_name, local.input.environment]))
    )
  )

  # Number of hours to retain ephemeral sandboxes (90 days)
  sandbox_retention_hours = "2160h"

  sandbox_dt = local.input.environment_type == "Ephemeral" ? formatdate("YYYY-MM-DD", timeadd(timestamp(), local.sandbox_retention_hours)) : "never"
  delete_dt  = local.input.deletion_date == null ? local.sandbox_dt : local.input.deletion_date

  raw_tags = merge(local.input.cost_center != null || local.input.not_applicable_enabled ? {
    "${local.tag_prefix}costcenter" = local.input.cost_center == null ? local.cstr["not_applicable"] : local.input.cost_center
    } : {}, local.input.owner_tags_enabled && (length(local.input.product_owners) > 0 || local.input.not_applicable_enabled) ? {
    "${local.tag_prefix}productowners" = length(local.input.product_owners) > 0 ? (
      join(local.cstr["tag_delimiter"], local.input.product_owners)
      ) : (
      local.cstr["not_applicable"]
    )
    } : {}, local.input.owner_tags_enabled && (length(local.input.code_owners) > 0 || local.input.not_applicable_enabled) ? {
    "${local.tag_prefix}codeowners" = length(local.input.code_owners) > 0 ? (
      join(local.cstr["tag_delimiter"], local.input.code_owners)
      ) : (
      local.cstr["not_applicable"]
    )
    } : {}, local.pm_info != null ? {
    "${local.tag_prefix}projectmgmtid" = local.pm_info
    } : {}, local.itsm_system_id != null ? {
    "${local.tag_prefix}systemid" = local.itsm_system_id
    } : {}, local.itsm_component_id != null ? {
    "${local.tag_prefix}componentid" = local.itsm_component_id
    } : {}, local.itsm_instance_id != null ? {
    "${local.tag_prefix}instanceid" = local.itsm_instance_id
    } : {}, {
    "${local.tag_prefix}environment"  = local.env_name
    "${local.tag_prefix}availability" = local.availability
    "${local.tag_prefix}managedby"    = local.managedby
    "${local.tag_prefix}deletiondate" = local.delete_dt
    }, local.input.security_review != null || local.input.not_applicable_enabled ? {
    "${local.tag_prefix}securityreview" = local.input.security_review == null ? local.cstr["not_applicable"] : local.input.security_review
    } : {}, local.input.privacy_review != null || local.input.not_applicable_enabled ? {
    "${local.tag_prefix}privacyreview" = local.input.privacy_review == null ? local.cstr["not_applicable"] : local.input.privacy_review
    } : {}, local.input.source_repo_tags_enabled ? {
    "${local.tag_prefix}sourcerepo"   = local.source_repo
    "${local.tag_prefix}sourcecommit" = local.source_commit
  } : {}, local.input.additional_tags)
  tag_names = keys(local.raw_tags)
  normalized_tags = { for k in local.tag_names : k =>
    replace(
      local.cstr["tag_lowercase"] ? lower(local.raw_tags[k]) : local.raw_tags[k],
      local.cstr["tag_replace_chars"],
      local.cstr["tag_replacement"]
    )
  }
  tags = { for k in local.tag_names : k =>
    length(local.normalized_tags[k]) > local.cstr["tag_length_limit"] ? (
      substr(local.normalized_tags[k], 0, local.cstr["tag_length_limit"])
      ) : (
      local.normalized_tags[k]
    )
  }

  # Data tags include data-specific tags plus additional data tags
  raw_data_tags = merge({
    "${local.tag_prefix}sensitivity" = local.sensitivity
    }, local.input.owner_tags_enabled && (length(local.input.data_owners) > 0 || local.input.not_applicable_enabled) ? {
    "${local.tag_prefix}dataowners" = length(local.input.data_owners) > 0 ? (
      join(local.cstr["tag_delimiter"], local.input.data_owners)
      ) : (
      local.cstr["not_applicable"]
    )
    } : {}, length(local.input.data_regs) > 0 || local.input.not_applicable_enabled ? {
    "${local.tag_prefix}dataregulations" = length(local.input.data_regs) > 0 ? (
      join(local.cstr["tag_delimiter"], local.input.data_regs)
      ) : (
      local.cstr["not_applicable"]
    )
  } : {}, local.input.additional_data_tags)
  data_tag_names = keys(local.raw_data_tags)
  normalized_data_tags = { for k in local.data_tag_names : k =>
    replace(
      local.cstr["tag_lowercase"] ? lower(local.raw_data_tags[k]) : local.raw_data_tags[k],
      local.cstr["tag_replace_chars"],
      local.cstr["tag_replacement"]
    )
  }
  data_tags = { for k in local.data_tag_names : k =>
    length(local.normalized_data_tags[k]) > local.cstr["tag_length_limit"] ? (
      substr(local.normalized_data_tags[k], 0, local.cstr["tag_length_limit"])
      ) : (
      local.normalized_data_tags[k]
    )
  }

  tags_as_list_of_maps = flatten([
    for key in keys(local.tags) : merge(
      {
        key                 = key
        value               = local.tags[key]
        propagate_at_launch = "true"
    })
  ])

  tags_as_kvp_list               = [for k, v in local.tags : format("%s=%s", k, v)]
  tags_as_comma_separated_string = join(",", local.tags_as_kvp_list)

  # Data tags transformations
  data_tags_as_list_of_maps = flatten([
    for key in keys(local.data_tags) : merge(
      {
        key                 = key
        value               = local.data_tags[key]
        propagate_at_launch = "true"
    })
  ])

  data_tags_as_kvp_list               = [for k, v in local.data_tags : format("%s=%s", k, v)]
  data_tags_as_comma_separated_string = join(",", local.data_tags_as_kvp_list)

  # Merging of inputs from parent context, if supplied, and this context's overrides
  output_context = {
    enabled                  = local.enabled
    environment_type         = local.input.environment_type
    cloud_provider           = local.input.cloud_provider
    name_prefix              = local.name_prefix
    namespace                = local.input.namespace
    name                     = local.input.name
    environment              = local.env
    environment_name         = local.env_name
    tag_prefix               = local.tag_prefix
    pm_platform              = local.input.pm_platform
    pm_project_code          = local.input.pm_project_code
    itsm_platform            = local.input.itsm_platform
    itsm_system_id           = local.input.itsm_system_id
    itsm_component_id        = local.input.itsm_component_id
    itsm_instance_id         = local.input.itsm_instance_id
    cost_center              = local.input.cost_center
    product_owners           = local.input.product_owners
    code_owners              = local.input.code_owners
    data_owners              = local.input.data_owners
    availability             = local.availability
    availability_values      = local.input.availability_values
    managedby                = local.managedby
    deletion_date            = local.delete_dt
    sensitivity              = local.sensitivity
    sensitivity_values       = local.input.sensitivity_values
    data_regs                = local.input.data_regs
    security_review          = local.input.security_review
    privacy_review           = local.input.privacy_review
    additional_tags          = local.input.additional_tags
    additional_data_tags     = local.input.additional_data_tags
    source_repo_tags_enabled = local.input.source_repo_tags_enabled
    system_prefixes_enabled  = local.input.system_prefixes_enabled
    not_applicable_enabled   = local.input.not_applicable_enabled
    owner_tags_enabled       = local.input.owner_tags_enabled
  }

}
