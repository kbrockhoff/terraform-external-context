output "name_prefix" {
  description = "Disambiguated ID or name prefix for resources in the context."
  value       = local.enabled ? local.name_prefix : ""
}

output "environment_type" {
  description = "Environment type for resource configuration defaults."
  value       = local.input.environment_type
}

output "tags" {
  description = "Normalized tags map."
  value       = local.enabled ? local.tags : {}
}

output "data_tags" {
  description = "Normalized data tags map."
  value       = local.enabled ? local.data_tags : {}
}


output "tags_as_list_of_maps" {
  description = "Additional tags as a list of maps, which can be used in several AWS resources."
  value       = local.tags_as_list_of_maps
}

output "tags_as_kvp_list" {
  description = "Tags as a list of key=value pairs."
  value       = local.tags_as_kvp_list
}

output "tags_as_comma_separated_string" {
  description = "Tags as a comma-separated string, which can be used by command line tools."
  value       = local.tags_as_comma_separated_string
}

output "data_tags_as_list_of_maps" {
  description = "Additional data tags as a list of maps, which can be used in several AWS resources."
  value       = local.data_tags_as_list_of_maps
}

output "data_tags_as_kvp_list" {
  description = "Data tags as a list of key=value pairs."
  value       = local.data_tags_as_kvp_list
}

output "data_tags_as_comma_separated_string" {
  description = "Data tags as a comma-separated string, which can be used by command line tools."
  value       = local.data_tags_as_comma_separated_string
}


output "normalized_context" {
  description = "Normalized context of this module."
  value       = local.output_context
}

output "context" {
  description = "Merged but otherwise unmodified input to this module, to be used as context input to other modules."
  value       = local.input
}
