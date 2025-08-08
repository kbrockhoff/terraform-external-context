# Primary context outputs
output "primary_name_prefix" {
  description = "Name prefix for primary environment"
  value       = module.primary_context.name_prefix
}

output "primary_tags" {
  description = "Tags for primary environment"
  value       = module.primary_context.tags
}

output "primary_data_tags" {
  description = "Data tags for primary environment"
  value       = module.primary_context.data_tags
}

output "primary_context" {
  description = "Full context output from primary module"
  value       = module.primary_context.context
}

# Failover context outputs
output "failover_name_prefix" {
  description = "Name prefix for failover environment"
  value       = module.failover_context.name_prefix
}

output "failover_tags" {
  description = "Tags for failover environment"
  value       = module.failover_context.tags
}

output "failover_data_tags" {
  description = "Data tags for failover environment"
  value       = module.failover_context.data_tags
}

output "failover_context" {
  description = "Full context output from failover module"
  value       = module.failover_context.context
}

# Comparison outputs to show inheritance
output "name_prefix_comparison" {
  description = "Comparison of name prefixes between environments"
  value = {
    primary  = module.primary_context.name_prefix
    failover = module.failover_context.name_prefix
  }
}

output "environment_comparison" {
  description = "Comparison of environment settings"
  value = {
    primary = {
      environment      = module.primary_context.context.environment
      environment_name = module.primary_context.context.environment_name
    }
    failover = {
      environment      = module.failover_context.context.environment
      environment_name = module.failover_context.context.environment_name
    }
  }
}

# Tag transformation examples
output "primary_tags_as_list_of_maps" {
  description = "Primary tags as list of maps (for AWS resources)"
  value       = module.primary_context.tags_as_list_of_maps
}

output "failover_data_tags_as_comma_separated_string" {
  description = "Failover data tags as comma-separated string (for CLI tools)"
  value       = module.failover_context.data_tags_as_comma_separated_string
}
