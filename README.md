# Terraform AWS S3 Bucket

[![License](https://img.shields.io/github/license/FollowTheProcess/terraform-aws-s3-bucket)](https://github.com/FollowTheProcess/terraform-aws-s3-bucket)
[![GitHub](https://img.shields.io/github/v/release/FollowTheProcess/terraform-aws-s3-bucket?logo=github&sort=semver)](https://github.com/FollowTheProcess/terraform-aws-s3-bucket)
[![CI](https://github.com/FollowTheProcess/terraform-aws-s3-bucket/workflows/CI/badge.svg)](https://github.com/FollowTheProcess/terraform-aws-s3-bucket/actions?query=workflow%3ACI)

## Summary

A Terraform module providing a simple, opinionated, best practice AWS S3 bucket:

- Public access block
- Bucket policy enforcing SSL access, SSE and encrypted uploads
- Easy toggle to turn this bucket into a suitable access log bucket
- Standardised access logging to another S3 bucket
- Simple default lifecycle policy that simply deletes objects after a configurable time, can be disabled or you may attach your own if your needs are more complex

> [!NOTE]
> I wrote this mainly for my own purposes, it is intentionally simple and does not support the full S3 bucket feature set. If you want something more complex and less opinionated, I suggest <https://github.com/cloudposse/terraform-aws-s3-bucket>

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name                                                                      | Version |
| ------------------------------------------------------------------------- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                   | ~> 6    |

## Providers

| Name                                              | Version |
| ------------------------------------------------- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.0.0   |

## Resources

| Name                                                                                                                                                                                  | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)                                                                           | resource    |
| [aws_s3_bucket_acl.log_delivery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl)                                                           | resource    |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration)                           | resource    |
| [aws_s3_bucket_logging.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging)                                                           | resource    |
| [aws_s3_bucket_ownership_controls.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls)                                     | resource    |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy)                                                             | resource    |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block)                                   | resource    |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource    |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning)                                                     | resource    |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)                                                         | data source |
| [aws_iam_policy_document.actual_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                    | data source |
| [aws_iam_policy_document.default_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                   | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)                                                                           | data source |

## Inputs

| Name                                                                                                        | Description                                                                                                                                                            | Type                                                                                         | Default                                                               | Required |
| ----------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- | --------------------------------------------------------------------- | :------: |
| <a name="input_bucket_policy_documents"></a> [bucket\_policy\_documents](#input\_bucket\_policy\_documents) | List of iam policy documents to apply to the bucket. Will be merged with default policy documents enforcing HTTPS and SSE                                              | `list(string)`                                                                               | `[]`                                                                  |    no    |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy)                                 | Destroy all bucket objects prior to destroying the bucket so that the bucket may be cleanly destroyed. This will cause irreversible data loss!                         | `bool`                                                                                       | `false`                                                               |    no    |
| <a name="input_is_logging_bucket"></a> [is\_logging\_bucket](#input\_is\_logging\_bucket)                   | Whether this bucket is intended to be an access logging bucket. Enables the 'log-delivery-write' ACL if true                                                           | `bool`                                                                                       | `false`                                                               |    no    |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn)                                     | The ARN of a KMS CMK with which to encrypt the bucket contents. If omitted, default S3 SSE is used                                                                     | `string`                                                                                     | `""`                                                                  |    no    |
| <a name="input_lifecycle_configuration"></a> [lifecycle\_configuration](#input\_lifecycle\_configuration)   | Simple bucket object lifecycle configuration with configurable expiry time. If needs are more complicated, use the module output `id` to attach your own configuration | <pre>object({<br/>    enabled         = bool<br/>    expiration_days = number<br/>  })</pre> | <pre>{<br/>  "enabled": true,<br/>  "expiration_days": 30<br/>}</pre> |    no    |
| <a name="input_logging_bucket_arn"></a> [logging\_bucket\_arn](#input\_logging\_bucket\_arn)                | The ARN of another S3 bucket into which to write access logs for this bucket. If omitted, access logging is not enabled                                                | `string`                                                                                     | `""`                                                                  |    no    |
| <a name="input_name"></a> [name](#input\_name)                                                              | The name for the S3 bucket, must be globally unique                                                                                                                    | `string`                                                                                     | n/a                                                                   |   yes    |
| <a name="input_object_ownership"></a> [object\_ownership](#input\_object\_ownership)                        | Policy for object ownership. Valid values are `BucketOwnerEnforced`, `BucketOwnerPreferred` or `ObjectWriter`                                                          | `string`                                                                                     | `"BucketOwnerEnforced"`                                               |    no    |
| <a name="input_region"></a> [region](#input\_region)                                                        | The name of the AWS region to provision the bucket. If omitted, the default region for the provider is used                                                            | `string`                                                                                     | `""`                                                                  |    no    |
| <a name="input_versioning_enabled"></a> [versioning\_enabled](#input\_versioning\_enabled)                  | Whether to enable bucket versioning                                                                                                                                    | `bool`                                                                                       | `true`                                                                |    no    |

## Outputs

| Name                                                                                                                        | Description                                                            |
| --------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| <a name="output_arn"></a> [arn](#output\_arn)                                                                               | The ARN of the S3 bucket                                               |
| <a name="output_bucket_domain_name"></a> [bucket\_domain\_name](#output\_bucket\_domain\_name)                              | Bucket domain name, will be of format `bucketname.s3.amazonaws.com`    |
| <a name="output_bucket_regional_domain_name"></a> [bucket\_regional\_domain\_name](#output\_bucket\_regional\_domain\_name) | The bucket region-specific domain name e.g. for a CloudFront S3 origin |
| <a name="output_id"></a> [id](#output\_id)                                                                                  | The name of the S3 bucket                                              |
<!-- END_TF_DOCS -->