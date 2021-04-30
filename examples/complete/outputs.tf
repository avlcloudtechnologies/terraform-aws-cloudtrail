output "cloudtrail_name" {
  description = "The name of the trail."
  value       = module.cloudtrail.cloudtrail_name
}

output "cloudtrail_arn" {
  description = "The Amazon Resource Name of the trail."
  value       = module.cloudtrail.cloudtrail_arn
}

output "kms_key_id" {
  description = "The KMS key id created for trail events and SNS."
  value       = module.cloudtrail.kms_key_id
}

output "cloudwatch_logs_role_arn" {
  description = "The IAM role ARN for the CloudWatch Logs endpoint to assume to write to a log group."
  value       = module.cloudtrail.cloudwatch_logs_role_arn
}

output "cloudwatch_logs_group_arn" {
  description = "The log group ARN to which CloudTrail logs are delivered"
  value       = module.cloudtrail.cloudwatch_logs_group_arn
}

output "cloudtrail_sns_topic_arn" {
  description = "Trail SNS topic."
  value       = module.cloudtrail.cloudtrail_sns_topic_arn
}
