# Brockhoff Cloud Context Terraform Module

Terraform module which creates standardized resource name prefixes and tags/labels which conform with
values expected by Brockhoff Terraform modules. It provides limited flexibility in adjusting tag/label
names.

## Features

- Standardized resource name prefix generation following Brockhoff conventions (24-char limit with smart truncation)
- Multi-cloud provider tag/label formatting for AWS, Azure, and GCP
- Environment type-based configuration with predefined defaults for different deployment stages
- Comprehensive tag normalization with character replacement and length limiting
- Multiple output formats for tags (maps, lists, comma-separated strings, key=value pairs)
- Automatic git repository URL detection and tagging
- Context inheritance for modular Terraform composition
- Data-specific tagging for resources handling sensitive information

## Usage

### Basic Example

```hcl
module "context" {
  source = "kbrockhoff/context/external"

  # Simple name-only approach
  name = "my-app"
}

# Use the context outputs in other resources
resource "aws_s3_bucket" "example" {
  bucket = "${module.context.name_prefix}-data"
  
  tags = module.context.tags
}
```

### Complete Example

```hcl
module "context" {
  source = "kbrockhoff/context/external"

  # Core identification
  cloud_provider    = "aws"
  namespace         = "myorg"
  name              = "webapp"
  environment       = "prod"
  environment_name  = "Production"
  environment_type  = "Production"

  # Governance and compliance
  cost_center       = "engineering"
  product_owners    = ["product@example.com"]
  code_owners       = ["platform@example.com", "webapp-team@example.com"]
  data_owners       = ["data-governance@example.com"]
  
  # Operational settings
  availability      = "always_on"
  sensitivity       = "confidential"
  data_regs         = ["GDPR", "SOX"]
  security_review   = "2024-01-15"
  privacy_review    = "2024-01-15"
  
  # Project management integration
  pm_platform       = "JIRA"
  pm_project_code   = "WEB"
  
  # ITSM integration
  itsm_platform     = "ServiceNow"
  itsm_system_id    = "SYS001"
  itsm_component_id = "COMP001"
  itsm_instance_id  = "INST001"

  # Additional custom tags
  additional_tags = {
    Team        = "Platform Engineering"
    CostOptimized = "true"
  }
  
  additional_data_tags = {
    DataClassification = "Confidential"
    RetentionPeriod    = "7years"
  }
}

# Example usage with multiple resource types
resource "aws_s3_bucket" "data" {
  bucket = "${module.context.name_prefix}-data"
  tags   = module.context.data_tags  # Use data_tags for data storage
}

resource "aws_lambda_function" "processor" {
  function_name = "${module.context.name_prefix}-processor"
  
  tags = module.context.tags  # Use regular tags for compute resources
}
```

### Context Inheritance Example

```hcl
# Primary environment context
module "primary_context" {
  source = "kbrockhoff/context/external"

  namespace        = "myorg"
  name             = "api"
  environment      = "prod-east"
  environment_name = "Production East"
  environment_type = "Production"
  
  cloud_provider   = "aws"
  cost_center      = "engineering"
  availability     = "always_on"
  sensitivity      = "confidential"
}

# Disaster recovery context - inherits most settings
module "dr_context" {
  source = "kbrockhoff/context/external"

  # Inherit all context from primary
  context = module.primary_context.context
  
  # Override only environment-specific values
  environment      = "prod-west"
  environment_name = "Production West (DR)"
  
  # Add DR-specific tags
  additional_tags = {
    Purpose = "disaster-recovery"
    Primary = module.primary_context.name_prefix
  }
}
```

### System Prefixes Example

```hcl
# With system prefixes enabled (default)
module "context_with_prefixes" {
  source = "kbrockhoff/context/external"

  name              = "api"
  pm_platform       = "JIRA"
  pm_project_code   = "API"
  itsm_platform     = "SNOW"
  itsm_system_id    = "BA12345"
  itsm_component_id = "AS1234567"
  
  # This is the default behavior
  system_prefixes_enabled = true
}

# Without system prefixes for cleaner tags
module "context_no_prefixes" {
  source = "kbrockhoff/context/external"

  name              = "api"
  pm_platform       = "JIRA"
  pm_project_code   = "API"
  itsm_platform     = "SNOW"
  itsm_system_id    = "BA12345"
  itsm_component_id = "AS1234567"
  
  # Disable system prefixes for shorter tag values
  system_prefixes_enabled = false
}

# Tags generated:
# With prefixes:    bc-projectmgmtid = "JIRA API", bc-systemid = "SNOW BA12345"
# Without prefixes: bc-projectmgmtid = "API",      bc-systemid = "BA12345"
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


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_external"></a> [external](#requirement\_external) | >= 2.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.5 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_data_tags"></a> [additional\_data\_tags](#input\_additional\_data\_tags) | Additional data tags for resources with data at rest (e.g. `map('DataClassification','Confidential')`) | `map(string)` | `{}` | no |
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional tags (e.g. `map('BusinessUnit','XYZ')`) | `map(string)` | `{}` | no |
| <a name="input_availability"></a> [availability](#input\_availability) | Standard name from enumerated list of availability requirements. (always\_on, business\_hours, preemptable) | `string` | `null` | no |
| <a name="input_availability_values"></a> [availability\_values](#input\_availability\_values) | List of allowed availability values | `list(string)` | <pre>[<br/>  "always_on",<br/>  "business_hours",<br/>  "preemptable"<br/>]</pre> | no |
| <a name="input_cloud_provider"></a> [cloud\_provider](#input\_cloud\_provider) | Public/private cloud provider [dc, aws, az, gcp, oci, ibm, do, vul, ali, cv]. | `string` | `null` | no |
| <a name="input_code_owners"></a> [code\_owners](#input\_code\_owners) | List of email addresses to contact for application issue resolution. | `list(string)` | `null` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br/>See description of individual variables for details.<br/>Leave string and numeric variables as `null` to use default value.<br/>Individual variable settings (non-null) override settings in context object,<br/>except for additional\_tags and additional\_data\_tags which are merged. | `any` | <pre>{<br/>  "additional_data_tags": {},<br/>  "additional_tags": {},<br/>  "availability": "preemptable",<br/>  "availability_values": [<br/>    "always_on",<br/>    "business_hours",<br/>    "preemptable"<br/>  ],<br/>  "cloud_provider": "dc",<br/>  "code_owners": [],<br/>  "cost_center": null,<br/>  "data_owners": [],<br/>  "data_regs": [],<br/>  "deletion_date": null,<br/>  "enabled": true,<br/>  "environment": null,<br/>  "environment_name": null,<br/>  "environment_type": "Development",<br/>  "itsm_component_id": null,<br/>  "itsm_instance_id": null,<br/>  "itsm_platform": null,<br/>  "itsm_system_id": null,<br/>  "managedby": "Terraform",<br/>  "name": null,<br/>  "namespace": null,<br/>  "owner_tags_enabled": true,<br/>  "pm_platform": null,<br/>  "pm_project_code": null,<br/>  "privacy_review": null,<br/>  "product_owners": [],<br/>  "security_review": null,<br/>  "sensitivity": "confidential",<br/>  "sensitivity_values": [<br/>    "public",<br/>    "internal",<br/>    "trusted-3rd-party",<br/>    "confidential",<br/>    "highly-confidential",<br/>    "client-classified"<br/>  ],<br/>  "source_repo_tags_enabled": true,<br/>  "system_prefixes_enabled": true,<br/>  "tag_prefix": "bc-"<br/>}</pre> | no |
| <a name="input_cost_center"></a> [cost\_center](#input\_cost\_center) | Cost center this resource should be billed to. | `string` | `null` | no |
| <a name="input_data_owners"></a> [data\_owners](#input\_data\_owners) | List of email addresses to contact for data governance issues. | `list(string)` | `null` | no |
| <a name="input_data_regs"></a> [data\_regs](#input\_data\_regs) | List of regulations which resource data must comply with. | `list(string)` | `null` | no |
| <a name="input_deletion_date"></a> [deletion\_date](#input\_deletion\_date) | Date resource should be deleted if still running. | `string` | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources. | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Abbreviation for the deployment environment. i.e. [sbox, dev, test, qa, uat, prod, prd-use1, prd-usw2, dr] | `string` | `null` | no |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | Full name for the deployment environment (can be more descriptive than the standard environment). | `string` | `null` | no |
| <a name="input_environment_type"></a> [environment\_type](#input\_environment\_type) | Environment type for resource configuration defaults. Select 'None' to use individual config values. | `string` | `"Development"` | no |
| <a name="input_itsm_component_id"></a> [itsm\_component\_id](#input\_itsm\_component\_id) | ITSM component identifier ID | `string` | `null` | no |
| <a name="input_itsm_instance_id"></a> [itsm\_instance\_id](#input\_itsm\_instance\_id) | ITSM instance identifier ID | `string` | `null` | no |
| <a name="input_itsm_platform"></a> [itsm\_platform](#input\_itsm\_platform) | IT Service Management platform (e.g., ServiceNow, JIRA Service Management) | `string` | `null` | no |
| <a name="input_itsm_system_id"></a> [itsm\_system\_id](#input\_itsm\_system\_id) | ITSM system identifier ID | `string` | `null` | no |
| <a name="input_managedby"></a> [managedby](#input\_managedby) | ID of the CI/CD platform or person who last updated the resource. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Unique name within that particular hierarchy level and resource type. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace which could be an organization, business unit, or other grouping. | `string` | `null` | no |
| <a name="input_owner_tags_enabled"></a> [owner\_tags\_enabled](#input\_owner\_tags\_enabled) | Enable owner tags (productowners, codeowners, dataowners) | `bool` | `true` | no |
| <a name="input_pm_platform"></a> [pm\_platform](#input\_pm\_platform) | System for project management ticketing (i.e. JIRA, SNOW). | `string` | `null` | no |
| <a name="input_pm_project_code"></a> [pm\_project\_code](#input\_pm\_project\_code) | The prefix used on your project management platform tickets. | `string` | `null` | no |
| <a name="input_privacy_review"></a> [privacy\_review](#input\_privacy\_review) | ID or date of last data privacy review or audit. | `string` | `null` | no |
| <a name="input_product_owners"></a> [product\_owners](#input\_product\_owners) | List of email addresses to contact with billing questions. | `list(string)` | `null` | no |
| <a name="input_security_review"></a> [security\_review](#input\_security\_review) | ID or date of last security review or audit | `string` | `null` | no |
| <a name="input_sensitivity"></a> [sensitivity](#input\_sensitivity) | Standard name from enumerated list for data sensitivity. (public, internal, trusted-3rd-party, confidential, highly-confidential, client-classified) | `string` | `null` | no |
| <a name="input_sensitivity_values"></a> [sensitivity\_values](#input\_sensitivity\_values) | List of allowed sensitivity values for data classification | `list(string)` | <pre>[<br/>  "public",<br/>  "internal",<br/>  "trusted-3rd-party",<br/>  "confidential",<br/>  "highly-confidential",<br/>  "client-classified"<br/>]</pre> | no |
| <a name="input_source_repo_tags_enabled"></a> [source\_repo\_tags\_enabled](#input\_source\_repo\_tags\_enabled) | Enable source repository tags | `bool` | `true` | no |
| <a name="input_system_prefixes_enabled"></a> [system\_prefixes\_enabled](#input\_system\_prefixes\_enabled) | Enable system prefixes in project management and ITSM tags | `bool` | `true` | no |
| <a name="input_tag_prefix"></a> [tag\_prefix](#input\_tag\_prefix) | Prefix for standardized tags | `string` | `"bc-"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_context"></a> [context](#output\_context) | Merged but otherwise unmodified input to this module, to be used as context input to other modules. |
| <a name="output_data_tags"></a> [data\_tags](#output\_data\_tags) | Normalized data tags map. |
| <a name="output_data_tags_as_comma_separated_string"></a> [data\_tags\_as\_comma\_separated\_string](#output\_data\_tags\_as\_comma\_separated\_string) | Data tags as a comma-separated string, which can be used by command line tools. |
| <a name="output_data_tags_as_kvp_list"></a> [data\_tags\_as\_kvp\_list](#output\_data\_tags\_as\_kvp\_list) | Data tags as a list of key=value pairs. |
| <a name="output_data_tags_as_list_of_maps"></a> [data\_tags\_as\_list\_of\_maps](#output\_data\_tags\_as\_list\_of\_maps) | Additional data tags as a list of maps, which can be used in several AWS resources. |
| <a name="output_environment_type"></a> [environment\_type](#output\_environment\_type) | Environment type for resource configuration defaults. |
| <a name="output_name_prefix"></a> [name\_prefix](#output\_name\_prefix) | Disambiguated ID or name prefix for resources in the context. |
| <a name="output_normalized_context"></a> [normalized\_context](#output\_normalized\_context) | Normalized context of this module. |
| <a name="output_tags"></a> [tags](#output\_tags) | Normalized tags map. |
| <a name="output_tags_as_comma_separated_string"></a> [tags\_as\_comma\_separated\_string](#output\_tags\_as\_comma\_separated\_string) | Tags as a comma-separated string, which can be used by command line tools. |
| <a name="output_tags_as_kvp_list"></a> [tags\_as\_kvp\_list](#output\_tags\_as\_kvp\_list) | Tags as a list of key=value pairs. |
| <a name="output_tags_as_list_of_maps"></a> [tags\_as\_list\_of\_maps](#output\_tags\_as\_list\_of\_maps) | Additional tags as a list of maps, which can be used in several AWS resources. |
<!-- END_TF_DOCS -->    

## License

This project is licensed under the Apache License, Version 2.0 - see the [LICENSE](LICENSE) file for details.
