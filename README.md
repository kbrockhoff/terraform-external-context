# Brockhoff Cloud Context Terraform Module

Terraform module which creates standardized resource name prefixes and tags/labels which conform with
values expected by Brockhoff Terraform modules. It provides limited flexibility in adjusting tag/label
names.

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
| <a name="input_additional_data_tags"></a> [additional\_data\_tags](#input\_additional\_data\_tags) | Additional data tags for resources with data at rest (e.g. `map('DataClassification','Confidential')` | `map(string)` | `{}` | no |
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional tags (e.g. `map('BusinessUnit','XYZ')` | `map(string)` | `{}` | no |
| <a name="input_availability"></a> [availability](#input\_availability) | Standard name from enumerated list of availability requirements. (always\_on, business\_hours, preemptable) | `string` | `null` | no |
| <a name="input_cloud_provider"></a> [cloud\_provider](#input\_cloud\_provider) | Public/private cloud provider [dc, aws, az, gcp, oci, ibm, do, vul, ali, cv]. | `string` | `null` | no |
| <a name="input_code_owners"></a> [code\_owners](#input\_code\_owners) | List of email addresses to contact for application issue resolution. | `list(string)` | `null` | no |
| <a name="input_confidentiality"></a> [confidentiality](#input\_confidentiality) | Standard name from enumerated list for data confidentiality. (public, confidential, client, private) | `string` | `null` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br/>See description of individual variables for details.<br/>Leave string and numeric variables as `null` to use default value.<br/>Individual variable settings (non-null) override settings in context object,<br/>except for additional\_tags and additional\_data\_tags which are merged. | `any` | <pre>{<br/>  "additional_data_tags": {},<br/>  "additional_tags": {},<br/>  "availability": "preemptable",<br/>  "cloud_provider": "dc",<br/>  "code_owners": [],<br/>  "confidentiality": "confidential",<br/>  "cost_center": null,<br/>  "data_owners": [],<br/>  "data_regs": [],<br/>  "deletion_date": null,<br/>  "deployer": "Terraform",<br/>  "enabled": true,<br/>  "environment": null,<br/>  "environment_name": null,<br/>  "environment_type": "Development",<br/>  "itsm_platform": null,<br/>  "itsm_project_code": null,<br/>  "name": null,<br/>  "namespace": null,<br/>  "privacy_review": null,<br/>  "product": null,<br/>  "product_owners": [],<br/>  "security_review": null,<br/>  "source_repo_tags_enabled": true,<br/>  "tag_prefix": "ck-"<br/>}</pre> | no |
| <a name="input_cost_center"></a> [cost\_center](#input\_cost\_center) | Cost center this resource should be billed to. | `string` | `null` | no |
| <a name="input_data_owners"></a> [data\_owners](#input\_data\_owners) | List of email addresses to contact for data governance issues. | `list(string)` | `null` | no |
| <a name="input_data_regs"></a> [data\_regs](#input\_data\_regs) | List of regulations which resource data must comply with. | `list(string)` | `null` | no |
| <a name="input_deletion_date"></a> [deletion\_date](#input\_deletion\_date) | Date resource should be deleted if still running. | `string` | `null` | no |
| <a name="input_deployer"></a> [deployer](#input\_deployer) | ID of the CI/CD platform or person who last updated the resource. | `string` | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources. | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Abbreviation for the deployment environment. i.e. [sbox, dev, test, qa, uat, prod, prd-use1, prd-usw2, dr] | `string` | `null` | no |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | Full name for the deployment environment (can be more descriptive than the standard environment). | `string` | `null` | no |
| <a name="input_environment_type"></a> [environment\_type](#input\_environment\_type) | Environment type for resource configuration defaults. Select 'None' to use individual config values. | `string` | `"Development"` | no |
| <a name="input_itsm_platform"></a> [itsm\_platform](#input\_itsm\_platform) | System for ticketing (i.e. JIRA, SNOW). | `string` | `null` | no |
| <a name="input_itsm_project_code"></a> [itsm\_project\_code](#input\_itsm\_project\_code) | The prefix used on your ITSM Platform tickets. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Unique name within that particular hierarchy level and resource type. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace which could be an organization, business unit, or other grouping. | `string` | `null` | no |
| <a name="input_privacy_review"></a> [privacy\_review](#input\_privacy\_review) | ID or date of last data privacy review or audit. | `string` | `null` | no |
| <a name="input_product"></a> [product](#input\_product) | Identifier for the product or project which created or owns this resource. | `string` | `null` | no |
| <a name="input_product_owners"></a> [product\_owners](#input\_product\_owners) | List of email addresses to contact with billing questions. | `list(string)` | `null` | no |
| <a name="input_security_review"></a> [security\_review](#input\_security\_review) | ID or date of last security review or audit | `string` | `null` | no |
| <a name="input_source_repo_tags_enabled"></a> [source\_repo\_tags\_enabled](#input\_source\_repo\_tags\_enabled) | Enable source repository tags | `bool` | `true` | no |
| <a name="input_tag_prefix"></a> [tag\_prefix](#input\_tag\_prefix) | Prefix for standardized tags | `string` | `"ck-"` | no |

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
