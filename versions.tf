terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.0"
      configuration_aliases = [aws.pricing]
    }
  }
}

locals {
  module_version = "v0.0.0"
}
