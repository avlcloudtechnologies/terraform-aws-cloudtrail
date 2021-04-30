variable "name" {
  description = "Namespace to be used on all resources"
  type        = string
}

variable "s3_bucket_name" {
  description = "Specifies the name of the S3 bucket designated for publishing log files."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to resources."
  type        = map(string)
  default     = {}
}

variable "s3_key_prefix" {
  description = "Specifies the S3 key prefix that follows the name of the bucket you have designated for log file delivery."
  type        = string
  default     = null
}

variable "enable_cloudwatch_logs" {
  description = "Enables Cloudtrail logs to write to ceated log group."
  type        = bool
  default     = false
}

variable "cloudwatch_logs_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire."
  type        = number
  default     = 365
}

variable "enable_logging" {
  description = "Enables logging for the trail. Defaults to true. Setting this to false will pause logging."
  type        = bool
  default     = false
}

variable "enable_log_file_validation" {
  description = "Specifies whether log file integrity validation is enabled."
  type        = bool
  default     = false
}

variable "include_global_service_events" {
  description = "Specifies whether the trail is publishing events from global services such as IAM to the log files."
  type        = bool
  default     = false
}

variable "is_multi_region_trail" {
  description = "Specifies whether the trail is created in the current region or in all regions."
  type        = bool
  default     = false
}

variable "is_organization_trail" {
  description = "Specifies whether the trail is an AWS Organizations trail. Organization trails log events for the master account and all member accounts. Can only be created in the organization master account."
  type        = bool
  default     = false
}

variable "enable_sns_notifications" {
  description = "Specifies whether to create SNS topic and send notification of log file delivery."
  type        = bool
  default     = false
}

variable "create_kms_key" {
  description = "Specifies whether to create kms key for cloudtrail and SNS. If 'kms_key_id' is set, need to set to 'false'."
  type        = bool
  default     = true
}
variable "kms_key_id" {
  description = "Specifies whether to use pre-created CMK. If used, set 'create_kms_key' to 'false'."
  type        = string
  default     = null
}

variable "kms_key_deletion_window_in_days" {
  description = "Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days."
  type        = number
  default     = 7
}

variable "event_selectors" {
  description = "Specifies a list of event selectors for enabling data event logging. See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail#event_selector."

  type = list(object({
    read_write_type           = string
    include_management_events = bool

    data_resource = object({
      type   = string
      values = list(string)
    })
  }))

  default = []
}

variable "insight_selectors" {
  description = "Specifies a list of insight selectors for identifying unusual operational activity. See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail#insight_selector."

  type = list(object({
    insight_type = string
  }))

  default = []
}