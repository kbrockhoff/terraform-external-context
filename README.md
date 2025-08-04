# Brockhoff Cloud Terraform Module

> **📋 Template Setup Instructions**
>
> After cloning this template repository, complete these setup steps:
>
> 1. **Configure GitHub repository settings:**
>    - Under **Settings → Actions → General**
>      - Enable **Allow all actions and reusable workflows**
>      - Set **Workflow permissions** to "Read and write permissions"
>      - Enable **Workflow permissions** "Allow GitHub Actions to create and approve pull requests"
>
> 2. **Configure repository secrets:**
>    - Under **Settings → Environments**
>      - Create `development` environment
>      - Add `AWS_ROLE_ARN` secret for GitHub Actions AWS access to your AWS development account
>    - Under **Settings → Secrets and variables → Actions → Repository secrets**
>      - Add `RELEASE_PLEASE_TOKEN` secret (Personal Access Token with repo permissions)
>    - For AWS authentication, ensure your IAM role has cross-account trust with GitHub OIDC
>
> 3. **Configure main branch protection:**
>    - Under **Settings → Rules → Rulesets**
>      - Create new ruleset which applies to default branch and is set to Active
>      - Enable **Require a pull request before merging**
>      - Enable other rules as needed for your workflow
>
> 4. **Replace placeholder text:**
>    - Find and replace all instances of `replace-me` with your actual module name
>    - Find and replace all instances of `replace` with appropriate values
>    - Update `CLOUD` and `XXX` placeholders with your target cloud provider and resources
>
> 5. **Update module metadata:**
>    - Modify `locals.tf` → `ModuleName` to match your module using Terraform registry naming conventions
>    - Update repository URLs and documentation
>    - Customize examples and tests for your specific resources

Terraform module which creates XXX resources on CLOUD. It takes an opinionated 
approach to resource placement, naming, tagging, and well-architected best 
practices.

## Features

- Feature 1
- Feature 2
- Feature 3
- Monthly cost estimate submodule
- Deployment pipeline least privilege IAM role submodule

## Usage

### Basic Example

```hcl
module "example" {
  source = "path/to/terraform-module"

  # ... other required arguments ...
}
```

### Complete Example

```hcl
module "example" {
  source = "path/to/terraform-module"

  # ... all available arguments ...
}
```

## Environment Type Configuration

The `environment_type` variable provides a standardized way to configure resource defaults based on environment 
characteristics. This follows cloud well-architected framework recommendations for different deployment stages. 
Resiliency settings comply with the recovery point objective (RPO) and recovery time objective (RTO) values in
the table below. Cost optimization settings focus on shutting down resources during off-hours.

### Available Environment Types

| Type | Use Case | Configuration Focus | RPO | RTO |
|------|----------|---------------------|-----|-----|
| `None` | Custom configuration | No defaults applied, use individual config values | N/A | N/A |
| `Ephemeral` | Temporary environments | Cost-optimized, minimal durability requirements | N/A | 48h |
| `Development` | Developer workspaces | Balanced cost and functionality for active development | 24h | 48h |
| `Testing` | Automated testing | Consistent, repeatable configurations | 24h | 48h |
| `UAT` | User acceptance testing | Production-like settings with some cost optimization | 12h | 24h |
| `Production` | Live systems | High availability, durability, and performance | 1h  | 4h  |
| `MissionCritical` | Critical production | Maximum reliability, redundancy, and monitoring | 5m  | 1h  |

### Usage Examples

#### Development Environment
```hcl
module "dev_resources" {
  source = "path/to/terraform-module"
  
  name_prefix      = "dev-usw2"
  environment_type = "Development"
  
  tags = {
    Environment = "development"
    Team        = "platform"
  }
}
```

#### Production Environment
```hcl
module "prod_resources" {
  source = "path/to/terraform-module"
  
  name_prefix      = "prod-usw2"
  environment_type = "Production"
  
  tags = {
    Environment = "production"
    Team        = "platform"
    Backup      = "required"
  }
}
```

#### Custom Configuration (None)
```hcl
module "custom_resources" {
  source = "path/to/terraform-module"
  
  name_prefix      = "custom-usw2"
  environment_type = "None"
  
  # Specify all individual configuration values
  # when environment_type is "None"
}
```
## Network Tags Configuration

Resources deployed to subnets use lookup by `NetworkTags` values to determine which subnets to deploy to. 
This eliminates the need to manage different subnet IDs variable values for each environment.

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_pricing"></a> [pricing](#module\_pricing) | ./modules/pricing | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_kms_alias.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_sns_topic.alarms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Organization unique prefix to use for resource names. Recommend including environment and region. e.g. 'prod-usw2' | `string` | n/a | yes |
| <a name="input_alarm_sns_topic_arn"></a> [alarm\_sns\_topic\_arn](#input\_alarm\_sns\_topic\_arn) | ARN of existing SNS topic to use for alarm notifications. Only used when create\_alarm\_sns\_topic is false. | `string` | `""` | no |
| <a name="input_alarms_enabled"></a> [alarms\_enabled](#input\_alarms\_enabled) | Enable CloudWatch alarms for monitoring autoscaling group health | `bool` | `false` | no |
| <a name="input_cost_estimation_enabled"></a> [cost\_estimation\_enabled](#input\_cost\_estimation\_enabled) | Set to false to disable estimation of monthly costs for provisioned resources | `bool` | `true` | no |
| <a name="input_create_alarm_sns_topic"></a> [create\_alarm\_sns\_topic](#input\_create\_alarm\_sns\_topic) | Set to true to create an SNS topic for alarm notifications. Set to false to use an existing topic specified in alarm\_sns\_topic\_arn. | `bool` | `true` | no |
| <a name="input_create_kms_key"></a> [create\_kms\_key](#input\_create\_kms\_key) | Set to true to create a customer-managed KMS key for encryption. Set to false to use an existing key specified in kms\_key\_id. | `bool` | `true` | no |
| <a name="input_data_tags"></a> [data\_tags](#input\_data\_tags) | Tags/labels to apply to all resources with data-at-rest | `map(string)` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `true` | no |
| <a name="input_environment_type"></a> [environment\_type](#input\_environment\_type) | Environment type for resource configuration defaults. Select 'None' to use individual config values. | `string` | `"Development"` | no |
| <a name="input_kms_key_deletion_window_days"></a> [kms\_key\_deletion\_window\_days](#input\_kms\_key\_deletion\_window\_days) | Number of days to wait before deleting KMS key when destroyed. Only used when create\_kms\_key is true. | `number` | `14` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | ARN or ID of existing KMS key to use for encryption. Only used when create\_kms\_key is false. | `string` | `""` | no |
| <a name="input_monitoring_enabled"></a> [monitoring\_enabled](#input\_monitoring\_enabled) | Launched EC2 instance will have detailed monitoring enabled. | `bool` | `false` | no |
| <a name="input_networktags_name"></a> [networktags\_name](#input\_networktags\_name) | Name of the network tags key used for subnet classification | `string` | `"NetworkTags"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags/labels to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alarm_sns_topic_arn"></a> [alarm\_sns\_topic\_arn](#output\_alarm\_sns\_topic\_arn) | ARN of the SNS topic used for alarm notifications |
| <a name="output_alarm_sns_topic_name"></a> [alarm\_sns\_topic\_name](#output\_alarm\_sns\_topic\_name) | Name of the SNS topic used for alarm notifications |
| <a name="output_cost_breakdown"></a> [cost\_breakdown](#output\_cost\_breakdown) | Detailed breakdown of monthly costs by service |
| <a name="output_kms_alias_name"></a> [kms\_alias\_name](#output\_kms\_alias\_name) | Name of the KMS key alias |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | ARN of the KMS key used for encryption |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | ID of the KMS key used for encryption |
| <a name="output_monthly_cost_estimate"></a> [monthly\_cost\_estimate](#output\_monthly\_cost\_estimate) | Estimated monthly cost in USD for module resources |
<!-- END_TF_DOCS -->    

## License

This project is licensed under the Apache License, Version 2.0 - see the [LICENSE](LICENSE) file for details.
