output "cloudtrail_name" {
  description = "The name of the Cloudtrail."
  value       = aws_cloudtrail.this.id
}

output "cloudtrail_arn" {
  description = "The Amazon Resource Name of the Cloudtrail."
  value       = aws_cloudtrail.this.arn
}

output "kms_key_id" {
  description = "The KMS key id created for trail events and SNS."
  value       = var.create_kms_key ? aws_kms_key.cloudtrail[0].key_id : null
}

output "cloudwatch_logs_role_arn" {
  description = "The IAM role ARN for the CloudWatch Logs endpoint to assume to write to a log group."
  value       = var.enable_cloudwatch_logs ? aws_iam_role.cloudtrail_cloudwatch_role[0].arn : null
}

output "cloudwatch_logs_group_arn" {
  description = "The log group ARN to which CloudTrail logs are delivered"
  value       = var.enable_cloudwatch_logs ? "${aws_cloudwatch_log_group.cloudtrail[0].arn}:*" : null
}

output "cloudtrail_sns_topic_arn" {
  description = "Cloudtrail SNS topic ARN."
  value       = var.enable_sns_notifications ? aws_sns_topic.cloudtrail[0].arn : null
}
