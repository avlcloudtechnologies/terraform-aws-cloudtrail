# Complete example with all supported arguments

Creates Cloudtrail with default module variable values.

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudtrail"></a> [cloudtrail](#module\_cloudtrail) | ../../ |  |
| <a name="module_cloudtrail_bucket"></a> [cloudtrail\_bucket](#module\_cloudtrail\_bucket) | terraform-aws-modules/s3-bucket/aws | 1.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.cloudtrail_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | The environement name resources are deployed in. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The namespace to be used on all resources. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to resources. | `map(string)` | <pre>{<br>  "Terraform": true<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudtrail_arn"></a> [cloudtrail\_arn](#output\_cloudtrail\_arn) | The Amazon Resource Name of the trail. |
| <a name="output_cloudtrail_name"></a> [cloudtrail\_name](#output\_cloudtrail\_name) | The name of the trail. |
| <a name="output_cloudtrail_sns_topic_arn"></a> [cloudtrail\_sns\_topic\_arn](#output\_cloudtrail\_sns\_topic\_arn) | Trail SNS topic. |
| <a name="output_cloudwatch_logs_group_arn"></a> [cloudwatch\_logs\_group\_arn](#output\_cloudwatch\_logs\_group\_arn) | The log group ARN to which CloudTrail logs are delivered |
| <a name="output_cloudwatch_logs_role_arn"></a> [cloudwatch\_logs\_role\_arn](#output\_cloudwatch\_logs\_role\_arn) | The IAM role ARN for the CloudWatch Logs endpoint to assume to write to a log group. |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | The KMS key id created for trail events and SNS. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->