# Github Actions IAM Terraform Module

This module creates an IAM role that can be assumed by GitHub Actions workflows. 
The role is configured with least privilege permissions needed to provision
and deprovision the parent module's resources.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.basic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.github_actions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.basic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | AWS account ID | `string` | n/a | yes |
| <a name="input_github_org"></a> [github\_org](#input\_github\_org) | GitHub organization name | `string` | n/a | yes |
| <a name="input_github_repo"></a> [github\_repo](#input\_github\_repo) | GitHub repository name | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Organization unique prefix to use for resource names. Recommend including environment and region. e.g. 'prod-usw2'. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | n/a | yes |
| <a name="input_s3_backend_bucket"></a> [s3\_backend\_bucket](#input\_s3\_backend\_bucket) | S3 bucket name for Terraform state backend | `string` | n/a | yes |
| <a name="input_s3_backend_lock_table"></a> [s3\_backend\_lock\_table](#input\_s3\_backend\_lock\_table) | DynamoDB table name for Terraform state locking | `string` | n/a | yes |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name for OIDC trust (e.g., 'development', 'staging', 'production') | `string` | `"*"` | no |
| <a name="input_partition"></a> [partition](#input\_partition) | AWS partition | `string` | `"aws"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags/labels to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_github_actions_policy_arn"></a> [github\_actions\_policy\_arn](#output\_github\_actions\_policy\_arn) | ARN of the GitHub Actions IAM policy |
| <a name="output_github_actions_policy_name"></a> [github\_actions\_policy\_name](#output\_github\_actions\_policy\_name) | Name of the GitHub Actions IAM policy |
| <a name="output_github_actions_role_arn"></a> [github\_actions\_role\_arn](#output\_github\_actions\_role\_arn) | ARN of the GitHub Actions IAM role |
| <a name="output_github_actions_role_name"></a> [github\_actions\_role\_name](#output\_github\_actions\_role\_name) | Name of the GitHub Actions IAM role |
<!-- END_TF_DOCS -->    