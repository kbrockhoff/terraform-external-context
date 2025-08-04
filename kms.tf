# ----
# KMS Key for encryption
# ----

# KMS Key for encrypting SNS topics and other resources
resource "aws_kms_key" "main" {
  count = var.enabled && var.create_kms_key ? 1 : 0

  description             = "Customer-managed key for ${local.name_prefix} module encryption"
  deletion_window_in_days = local.effective_config.kms_key_deletion_window_days
  enable_key_rotation     = true

  policy = data.aws_iam_policy_document.kms_key_policy[0].json

  tags = merge(local.common_data_tags, {
    Name = "${local.name_prefix}-cmk"
  })
}

# KMS Key Alias for easier reference
resource "aws_kms_alias" "main" {
  count = var.enabled && var.create_kms_key ? 1 : 0

  name          = "alias/${local.name_prefix}-cmk"
  target_key_id = aws_kms_key.main[0].key_id
}

# KMS Key Policy - allows account root and SNS service access
data "aws_iam_policy_document" "kms_key_policy" {
  count = var.enabled && var.create_kms_key ? 1 : 0

  # Allow account root full access to the key
  statement {
    sid    = "EnableRootAccess"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:${local.partition}:iam::${local.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalAccount"
      values   = [local.account_id]
    }
  }

  # Allow SNS service to use the key
  statement {
    sid    = "AllowSNSAccess"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["sns.${local.dns_suffix}"]
    }
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*"
    ]
    resources = ["*"]
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = [true]
    }
  }
}
