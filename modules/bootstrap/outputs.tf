output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions IAM role"
  value       = var.enabled ? aws_iam_role.github_actions[0].arn : null
}

output "github_actions_role_name" {
  description = "Name of the GitHub Actions IAM role"
  value       = var.enabled ? aws_iam_role.github_actions[0].name : null
}

output "github_actions_policy_arn" {
  description = "ARN of the GitHub Actions IAM policy"
  value       = var.enabled ? aws_iam_policy.basic[0].arn : null
}

output "github_actions_policy_name" {
  description = "Name of the GitHub Actions IAM policy"
  value       = var.enabled ? aws_iam_policy.basic[0].name : null
}
