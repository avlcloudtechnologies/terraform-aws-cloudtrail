provider "aws" {
  region = "eu-west-1"
}

locals {
  cloudtrail_bucket_name = "${var.name}-${var.environment}-cloudtrail-${data.aws_caller_identity.current.id}"
}

data "aws_caller_identity" "current" {
}

############
# Cloudtrail
############
module "cloudtrail" {
  source = "../../"

  name                              = "${var.name}-${var.environment}"
  s3_bucket_name                    = module.cloudtrail_bucket.this_s3_bucket_id
  s3_key_prefix                     = "cloudtrail"
  enable_cloudwatch_logs            = true
  cloudwatch_logs_retention_in_days = 365
  enable_logging                    = true
  enable_log_file_validation        = true
  include_global_service_events     = true
  is_multi_region_trail             = true
  is_organization_trail             = true
  enable_sns_notifications          = true
  create_kms_key                    = true

  event_selectors = [
    {
      read_write_type           = "All"
      include_management_events = true
      data_resource = {
        type   = "AWS::Lambda::Function"
        values = ["arn:aws:lambda"]
      }
    },
    {
      read_write_type           = "WriteOnly"
      include_management_events = true
      data_resource = {
        type   = "AWS::S3::Object"
        values = ["arn:aws:s3:::"]
      },
    },
  ]

  insight_selectors = [
    {
      insight_type = "ApiCallRateInsight"
    }
  ]

  tags = var.tags
}

############
# S3 BUCKETS
############
data "aws_iam_policy_document" "cloudtrail_bucket_policy" {

  statement {
    sid = "AWSCloudTrailAclCheck"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",
    ]

    resources = [
      "arn:aws:s3:::${local.cloudtrail_bucket_name}",
    ]
  }

  statement {
    sid = "AWSCloudTrailWrite"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${local.cloudtrail_bucket_name}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values = [
        "bucket-owner-full-control",
      ]
    }
  }
}

module "cloudtrail_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "1.25.0"

  bucket        = local.cloudtrail_bucket_name
  acl           = "log-delivery-write"
  force_destroy = true
  attach_policy = true
  policy        = data.aws_iam_policy_document.cloudtrail_bucket_policy.json

  versioning = {
    enabled = true
  }

  logging = {
    target_bucket = module.s3_access_bucket.this_s3_bucket_id
    target_prefix = "log/"
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
}

module "s3_access_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "1.25.0"

  bucket        = "${local.cloudtrail_bucket_name}-access-logs"
  acl           = "log-delivery-write"
  force_destroy = true

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
}
