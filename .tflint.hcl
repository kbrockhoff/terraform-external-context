config {
  # Enable TFLint to check module sources
  call_module_type = "local"
  
  # Force the use of color output
  force = false
  
  # Disable rules by default and only enable specific ones
  disabled_by_default = false
}

# AWS provider plugin
plugin "aws" {
  enabled = true
  version = "0.41.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# Custom rules for this module
rule "terraform_workspace_remote" {
  enabled = false  # Allow local state for examples
}