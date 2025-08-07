locals {
  default_constraints = {
    id_replace_chars  = "/[^a-z0-9_-]/"
    id_replacement    = ""
    id_delimiter      = "-"
    id_length_limit   = 63
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
    enabled              = var.enabled == null ? var.context.enabled : var.enabled
    environment_type     = var.environment_type == null ? var.context.environment_type : var.environment_type
    cloud_provider       = var.cloud_provider == null ? var.context.cloud_provider : var.cloud_provider
    namespace            = var.namespace == null ? var.context.namespace : var.namespace
    name                 = var.name == null ? var.context.name : var.name
    environment          = var.environment == null ? var.context.environment : var.environment
    environment_name     = var.environment_name == null ? var.context.environment_name : var.environment_name
    cost_center          = var.cost_center == null ? var.context.cost_center : var.cost_center
    project              = var.project == null ? var.context.project : var.project
    project_owners       = var.project_owners == null ? var.context.project_owners : var.project_owners
    code_owners          = var.code_owners == null ? var.context.code_owners : var.code_owners
    data_owners          = var.data_owners == null ? var.context.data_owners : var.data_owners
    availability         = var.availability == null ? var.context.availability : var.availability
    deployer             = var.deployer == null ? var.context.deployer : var.deployer
    deletion_date        = var.deletion_date == null ? var.context.deletion_date : var.deletion_date
    confidentiality      = var.confidentiality == null ? var.context.confidentiality : var.confidentiality
    data_regs            = var.data_regs == null ? var.context.data_regs : var.data_regs
    security_review      = var.security_review == null ? var.context.security_review : var.security_review
    privacy_review       = var.privacy_review == null ? var.context.privacy_review : var.privacy_review
    additional_tags      = merge(var.context.additional_tags, var.additional_tags)
    additional_data_tags = merge(var.context.additional_data_tags, var.additional_data_tags)
  }

  cstr = merge(local.default_constraints, lookup(local.cp_constraints_map, local.input.cloud_provider, {}))

  env      = local.input.environment
  env_name = local.input.environment_name == null ? local.env : local.input.environment_name
  enabled  = local.input.enabled == null ? true : local.input.enabled

  # Name prefix generation logic following Brockhoff standards
  # Rule 1: If namespace, environment, and name are provided, join with hyphens
  # Rule 2: If only name is provided (namespace and environment are null/empty), use name only

  generated_name_prefix = local.input.namespace == null || local.input.environment == null ? (
    local.input.name
    ) : (
    lower(join("-", [local.input.namespace, local.input.environment, local.input.name]))
  )

  # Ensure compliance with /^[a-z][a-z0-9-]{1,15}$/ by truncating if necessary
  # The name_prefix should be 2-16 characters total
  name_prefix = length(local.generated_name_prefix) > 16 ? substr(local.generated_name_prefix, 0, 16) : local.generated_name_prefix

  sandbox_dt = local.input.environment_type == "Ephemeral" ? formatdate("YYYY-MM-DD", timeadd(timestamp(), "2160h")) : "never"
  delete_dt  = local.input.deletion_date == null ? local.sandbox_dt : local.input.deletion_date

  raw_tags = merge({
    ck-project    = local.input.project == null ? local.cstr["not_applicable"] : local.input.project
    ck-costcenter = local.input.cost_center == null ? local.cstr["not_applicable"] : local.input.cost_center
    ck-projectowners = length(local.input.project_owners) > 0 ? (
      join(local.cstr["tag_delimiter"], local.input.project_owners)
      ) : (
      local.cstr["not_applicable"]
    )
    ck-codeowners = length(local.input.code_owners) > 0 ? (
      join(local.cstr["tag_delimiter"], local.input.code_owners)
      ) : (
      local.cstr["not_applicable"]
    )
    ck-dataowners = length(local.input.data_owners) > 0 ? (
      join(local.cstr["tag_delimiter"], local.input.data_owners)
      ) : (
      local.cstr["not_applicable"]
    )
    ck-environment     = local.env_name
    ck-availability    = local.input.availability
    ck-deployer        = local.input.deployer
    ck-deletiondate    = local.delete_dt
    ck-confidentiality = local.input.confidentiality
    ck-dataregulations = length(local.input.data_regs) > 0 ? (
      join(local.cstr["tag_delimiter"], local.input.data_regs)
      ) : (
      local.cstr["not_applicable"]
    )
    ck-securityreview = local.input.security_review == null ? local.cstr["not_applicable"] : local.input.security_review
    ck-privacyreview  = local.input.privacy_review == null ? local.cstr["not_applicable"] : local.input.privacy_review
  }, local.input.additional_tags)
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

  # Data tags combine standard tags with additional data tags
  raw_data_tags  = merge(local.raw_tags, local.input.additional_data_tags)
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
  tags_all = merge(
    local.tags,
    local.cstr["tag_lowercase"] ? { name = local.name_prefix } : { Name = local.name_prefix }
  )

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

  # Merging of inputs from parent context, if supplied, and this context's overrides
  output_context = {
    enabled              = local.enabled
    environment_type     = local.input.environment_type
    cloud_provider       = local.input.cloud_provider
    name_prefix          = local.name_prefix
    namespace            = local.input.namespace
    name                 = local.input.name
    environment          = local.input.environment
    environment_name     = local.input.environment_name
    cost_center          = local.input.cost_center
    project              = local.input.project
    project_owners       = local.input.project_owners
    code_owners          = local.input.code_owners
    data_owners          = local.input.data_owners
    availability         = local.input.availability
    deployer             = local.input.deployer
    deletion_date        = local.input.deletion_date
    confidentiality      = local.input.confidentiality
    data_regs            = local.input.data_regs
    security_review      = local.input.security_review
    privacy_review       = local.input.privacy_review
    additional_tags      = local.input.additional_tags
    additional_data_tags = local.input.additional_data_tags
  }

}
