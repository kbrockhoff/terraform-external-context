terraform {
  required_version = ">= 1.5"

  required_providers {
    external = {
      source  = "hashicorp/external"
      version = ">= 2.3"
    }
  }
}