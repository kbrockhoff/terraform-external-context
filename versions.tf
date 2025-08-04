terraform {
  required_version = ">= 1.5"

  required_providers {
    external = {
      source                = "hashicorp/external"
      version               = ">= 2.0"
    }
  }
}

locals {
  module_version = "v0.0.0"
}
