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

  name           = "${var.name}-${var.environment}"
  s3_bucket_name = module.cloudtrail_bucket.this_s3_bucket_id

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

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
}
