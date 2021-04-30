data "aws_region" "current" {
}

data "aws_caller_identity" "current" {
}

############
# Cloudwatch
############
data "aws_iam_policy_document" "cloudtrail_assume_role" {

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "cloudtrail_cloudwatch_logs" {

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${var.name}-cloudtrail-log-group:*"]
  }
}

resource "aws_iam_role" "cloudtrail_cloudwatch_role" {
  count = var.enable_cloudwatch_logs ? 1 : 0

  name               = "${var.name}-cloudtrail-iam-role"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_role.json

  tags = var.tags
}

resource "aws_iam_policy" "cloudtrail_cloudwatch_logs" {
  count = var.enable_cloudwatch_logs ? 1 : 0

  name   = "${var.name}-cloudtrail-cloudwatch-logs-policy"
  policy = data.aws_iam_policy_document.cloudtrail_cloudwatch_logs.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  count = var.enable_cloudwatch_logs ? 1 : 0

  policy_arn = aws_iam_policy.cloudtrail_cloudwatch_logs[0].arn
  role       = aws_iam_role.cloudtrail_cloudwatch_role[0].name
}

resource "aws_cloudwatch_log_group" "cloudtrail" {
  count = var.enable_cloudwatch_logs ? 1 : 0

  name              = "${var.name}-cloudtrail-log-group"
  retention_in_days = var.cloudwatch_logs_retention_in_days
  kms_key_id        = var.create_kms_key ? aws_kms_key.cloudtrail[0].arn : data.aws_kms_key.cloudtrail[0].arn

  tags = var.tags
}

##########
# KMS keys
##########
data "aws_iam_policy_document" "cloudtrail_kms_key" {

  statement {
    sid = "Enable IAM User Permissions"

    effect = "Allow"

    actions = ["kms:*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    resources = ["*"]
  }

  statement {
    sid = "Allow CloudTrail to encrypt logs"

    effect = "Allow"

    actions = ["kms:GenerateDataKey*"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"]
    }
  }

  statement {
    sid = "Allow CloudTrail to describe key"

    effect = "Allow"

    actions = ["kms:DescribeKey"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    resources = ["*"]
  }

  statement {
    sid = "Allow principals in the account to decrypt log files"

    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom",
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"]
    }
  }

  statement {
    sid = "Allow alias creation during setup"

    effect = "Allow"

    actions = ["kms:CreateAlias"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["ec2.${data.aws_region.current.name}.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

  }

  statement {
    sid = "Enable cross account log decryption"

    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom",
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"]
    }
  }

  statement {
    sid = "Allow logs KMS access"

    effect = "Allow"

    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]

    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
    }

    resources = ["*"]
  }

  statement {
    sid = "Allow send notifications to SNS topic"

    effect = "Allow"

    actions = [
      "kms:GenerateDataKey*",
      "kms:Decrypt"
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    resources = ["*"]
  }
}

resource "aws_kms_key" "cloudtrail" {
  count = var.create_kms_key ? 1 : 0

  description             = "KMS key to encrypt the logs delivered by CloudTrail"
  deletion_window_in_days = var.kms_key_deletion_window_in_days
  policy                  = data.aws_iam_policy_document.cloudtrail_kms_key.json

  tags = var.tags
}

resource "aws_kms_alias" "cloudtrail" {
  count = var.create_kms_key ? 1 : 0

  name          = "alias/${var.name}-cloudtrail"
  target_key_id = aws_kms_key.cloudtrail[0].key_id
}

#####
# SNS
#####
resource "aws_sns_topic" "cloudtrail" {
  count = var.enable_sns_notifications ? 1 : 0

  name              = "${var.name}-cloudtrail-sns"
  kms_master_key_id = var.create_kms_key ? aws_kms_key.cloudtrail[0].key_id : var.kms_key_id

  tags = var.tags
}

data "aws_iam_policy_document" "cloudtrail_sns" {
  count = var.enable_sns_notifications ? 1 : 0

  statement {
    sid = "AllowSNSPublish"

    effect = "Allow"

    actions = ["sns:Publish"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    resources = [aws_sns_topic.cloudtrail[0].arn]
  }
}

resource "aws_sns_topic_policy" "cloudtrail" {
  count = var.enable_sns_notifications ? 1 : 0

  arn    = aws_sns_topic.cloudtrail[0].arn
  policy = data.aws_iam_policy_document.cloudtrail_sns[0].json
}

############
# Cloudtrail
############
data "aws_kms_key" "cloudtrail" {
  count = var.create_kms_key ? 0 : 1

  key_id = var.kms_key_id
}

resource "aws_cloudtrail" "this" {
  name = "${var.name}-cloudtrail"

  s3_bucket_name                = var.s3_bucket_name
  s3_key_prefix                 = var.s3_key_prefix
  cloud_watch_logs_role_arn     = var.enable_cloudwatch_logs ? aws_iam_role.cloudtrail_cloudwatch_role[0].arn : null
  cloud_watch_logs_group_arn    = var.enable_cloudwatch_logs ? "${aws_cloudwatch_log_group.cloudtrail[0].arn}:*" : null
  enable_log_file_validation    = var.enable_log_file_validation
  enable_logging                = var.enable_logging
  include_global_service_events = var.include_global_service_events
  is_multi_region_trail         = var.is_multi_region_trail
  is_organization_trail         = var.is_organization_trail
  kms_key_id                    = var.create_kms_key && var.kms_key_id == null ? aws_kms_key.cloudtrail[0].arn : data.aws_kms_key.cloudtrail[0].arn
  sns_topic_name                = var.enable_sns_notifications ? aws_sns_topic.cloudtrail[0].arn : null

  tags = var.tags

  dynamic "event_selector" {
    for_each = var.event_selectors
    content {
      include_management_events = lookup(event_selector.value, "include_management_events", null)
      read_write_type           = lookup(event_selector.value, "read_write_type", null)
      data_resource {
        type   = lookup(event_selector.value.data_resource, "type", null)
        values = lookup(event_selector.value.data_resource, "values", null)
      }
    }
  }

  dynamic "insight_selector" {
    for_each = var.insight_selectors
    content {
      insight_type = lookup(insight_selector.value, "insight_type", null)
    }
  }
}