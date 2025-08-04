# ----
# Pricing Calculator
# ----

module "pricing" {
  source = "./modules/pricing"

  providers = {
    aws = aws.pricing
  }

  enabled        = var.enabled && var.cost_estimation_enabled
  region         = local.region
  create_kms_key = var.enabled && var.create_kms_key
}
