# GitHub Actions OIDC Provider
data "aws_iam_openid_connect_provider" "github_actions" {
  count = var.enabled ? 1 : 0
  url   = "https://token.actions.githubusercontent.com"
}

# IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions" {
  count = var.enabled ? 1 : 0
  name  = "${var.name_prefix}-github-actions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.github_actions[0].arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:environment:${var.environment}"
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-github-actions"
  })
}

# IAM Policy Document for S3 Backend and Basic Terraform Operations
data "aws_iam_policy_document" "basic" {
  count = var.enabled ? 1 : 0

  # S3 Backend Operations
  statement {
    sid    = "TerraformStateS3Access"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:GetBucketVersioning",
      "s3:GetBucketLocation",
    ]
    resources = [
      "arn:${var.partition}:s3:::${var.s3_backend_bucket}",
      "arn:${var.partition}:s3:::${var.s3_backend_bucket}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalAccount"
      values   = [var.account_id]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = [true]
    }
  }

  # DynamoDB State Locking
  statement {
    sid    = "TerraformStateLocking"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable",
    ]
    resources = [
      "arn:${var.partition}:dynamodb:${var.region}:${var.account_id}:table/${var.s3_backend_lock_table}"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalAccount"
      values   = [var.account_id]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [var.region]
    }
  }

  # Basic AWS API access for resource management
  statement {
    sid    = "BasicAWSAccess"
    effect = "Allow"
    actions = [
      "sts:GetCallerIdentity",
    ]
    resources = ["*"]
  }

  # Pricing API access (required for cost estimation)
  statement {
    sid    = "PricingAPIAccess"
    effect = "Allow"
    actions = [
      "freetier:GetAccountPlanState",
      "pricing:GetAttributeValues",
      "pricing:GetProducts",
    ]
    resources = ["*"]
  }

}

# IAM Policy (standalone)
resource "aws_iam_policy" "basic" {
  count       = var.enabled ? 1 : 0
  name        = "${var.name_prefix}-github-actions-basic"
  description = "Basic permissions for GitHub Actions CI/CD operations"
  policy      = data.aws_iam_policy_document.basic[0].json

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-github-actions-basic"
  })
}

# IAM Policy Attachment
resource "aws_iam_role_policy_attachment" "basic" {
  count      = var.enabled ? 1 : 0
  role       = aws_iam_role.github_actions[0].name
  policy_arn = aws_iam_policy.basic[0].arn
}
