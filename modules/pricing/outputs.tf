output "monthly_cost_estimate" {
  description = "Total estimated monthly cost in USD for module resources"
  value       = local.pricing_enabled ? local.total_monthly_cost : 0
}

output "cost_breakdown" {
  description = "Detailed breakdown of monthly costs by service"
  value       = local.pricing_enabled ? local.costs : {}
}
