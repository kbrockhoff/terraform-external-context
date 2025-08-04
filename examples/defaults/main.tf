# Main AWS provider - uses the current region
provider "aws" {
  # This is the default provider used for VPC resources
}

# Pricing provider - always uses us-east-1 where the AWS Pricing API is available
provider "aws" {
  alias  = "pricing"
  region = "us-east-1"
}

module "main" {
  source = "../../"

  providers = {
    aws         = aws
    aws.pricing = aws.pricing
  }

  name_prefix = var.name_prefix
  tags = {
    Example = "defaults"
  }
}
