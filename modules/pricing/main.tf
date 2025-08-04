# ----
# KMS Pricing Data
# ----

# KMS pricing
data "aws_pricing_product" "kms" {
  count = local.pricing_enabled ? 1 : 0

  service_code = "AWSKMS"

  filters {
    field = "productFamily"
    value = "Encryption Key"
  }

  filters {
    field = "usagetype"
    value = "${var.region}-KMS-Keys"
  }
}
