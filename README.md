# AWS Cloudtrail Terraform module

![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/avlcloudtechnologies/terraform-aws-cloudtrail)

This module handles creation of AWS Cloudtrail and related resources. Cloudtrail S3 bucket is created outside of the module. 

## Pre-requisites
Before this module can be used, please ensure that the following pre-requisites are met:
- Create Cloudtrail S3 bucket. Please check examples.

## Usage
Below is a complete example without the S3 bucket creation part. More examples can be found in the [examples](https://github.com/avlcloudtechnologies/terraform-aws-cloudtrail/tree/master/examples) directory.


```hcl
module "cloudtrail" {
  source = "./modules/cloudtrail"

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

  tags = {
    foo = "bar"
  }
}
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.26 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.36 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.36 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudtrail.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail) | resource |
| [aws_cloudwatch_log_group.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.cloudtrail_cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.cloudtrail_cloudwatch_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_sns_topic.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_policy.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.cloudtrail_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudtrail_cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudtrail_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudtrail_sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_kms_key.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudwatch_logs_retention_in_days"></a> [cloudwatch\_logs\_retention\_in\_days](#input\_cloudwatch\_logs\_retention\_in\_days) | Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire. | `number` | `365` | no |
| <a name="input_create_kms_key"></a> [create\_kms\_key](#input\_create\_kms\_key) | Specifies whether to create kms key for cloudtrail and SNS. If 'kms\_key\_id' is set, need to set to 'false'. | `bool` | `true` | no |
| <a name="input_enable_cloudwatch_logs"></a> [enable\_cloudwatch\_logs](#input\_enable\_cloudwatch\_logs) | Enables Cloudtrail logs to write to ceated log group. | `bool` | `false` | no |
| <a name="input_enable_log_file_validation"></a> [enable\_log\_file\_validation](#input\_enable\_log\_file\_validation) | Specifies whether log file integrity validation is enabled. | `bool` | `false` | no |
| <a name="input_enable_logging"></a> [enable\_logging](#input\_enable\_logging) | Enables logging for the trail. Defaults to true. Setting this to false will pause logging. | `bool` | `false` | no |
| <a name="input_enable_sns_notifications"></a> [enable\_sns\_notifications](#input\_enable\_sns\_notifications) | Specifies whether to create SNS topic and send notification of log file delivery. | `bool` | `false` | no |
| <a name="input_event_selectors"></a> [event\_selectors](#input\_event\_selectors) | Specifies a list of event selectors for enabling data event logging. See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail#event_selector. | <pre>list(object({<br>    read_write_type           = string<br>    include_management_events = bool<br><br>    data_resource = object({<br>      type   = string<br>      values = list(string)<br>    })<br>  }))</pre> | `[]` | no |
| <a name="input_include_global_service_events"></a> [include\_global\_service\_events](#input\_include\_global\_service\_events) | Specifies whether the trail is publishing events from global services such as IAM to the log files. | `bool` | `false` | no |
| <a name="input_insight_selectors"></a> [insight\_selectors](#input\_insight\_selectors) | Specifies a list of insight selectors for identifying unusual operational activity. See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail#insight_selector. | <pre>list(object({<br>    insight_type = string<br>  }))</pre> | `[]` | no |
| <a name="input_is_multi_region_trail"></a> [is\_multi\_region\_trail](#input\_is\_multi\_region\_trail) | Specifies whether the trail is created in the current region or in all regions. | `bool` | `false` | no |
| <a name="input_is_organization_trail"></a> [is\_organization\_trail](#input\_is\_organization\_trail) | Specifies whether the trail is an AWS Organizations trail. Organization trails log events for the master account and all member accounts. Can only be created in the organization master account. | `bool` | `false` | no |
| <a name="input_kms_key_deletion_window_in_days"></a> [kms\_key\_deletion\_window\_in\_days](#input\_kms\_key\_deletion\_window\_in\_days) | Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days. | `number` | `7` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | Specifies whether to use pre-created CMK. If used, set 'create\_kms\_key' to 'false'. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Namespace to be used on all resources | `string` | n/a | yes |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | Specifies the name of the S3 bucket designated for publishing log files. | `string` | n/a | yes |
| <a name="input_s3_key_prefix"></a> [s3\_key\_prefix](#input\_s3\_key\_prefix) | Specifies the S3 key prefix that follows the name of the bucket you have designated for log file delivery. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudtrail_arn"></a> [cloudtrail\_arn](#output\_cloudtrail\_arn) | The Amazon Resource Name of the Cloudtrail. |
| <a name="output_cloudtrail_name"></a> [cloudtrail\_name](#output\_cloudtrail\_name) | The name of the Cloudtrail. |
| <a name="output_cloudtrail_sns_topic_arn"></a> [cloudtrail\_sns\_topic\_arn](#output\_cloudtrail\_sns\_topic\_arn) | Cloudtrail SNS topic ARN. |
| <a name="output_cloudwatch_logs_group_arn"></a> [cloudwatch\_logs\_group\_arn](#output\_cloudwatch\_logs\_group\_arn) | The log group ARN to which CloudTrail logs are delivered |
| <a name="output_cloudwatch_logs_role_arn"></a> [cloudwatch\_logs\_role\_arn](#output\_cloudwatch\_logs\_role\_arn) | The IAM role ARN for the CloudWatch Logs endpoint to assume to write to a log group. |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | The KMS key id created for trail events and SNS. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->