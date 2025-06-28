variable "name" {
  description = "The name for the S3 bucket, must be globally unique"
  type        = string
}

variable "region" {
  description = "The name of the AWS region to provision the bucket. If omitted, the default region for the provider is used"
  type        = string
  default     = ""
}

variable "object_ownership" {
  description = "Policy for object ownership. Valid values are `BucketOwnerEnforced`, `BucketOwnerPreferred` or `ObjectWriter`"
  type        = string
  default     = "BucketOwnerEnforced"

  validation {
    condition     = can(regex("^(BucketOwnerEnforced|BucketOwnerPreferred|ObjectWriter)$", var.object_ownership))
    error_message = "Valid values are `BucketOwnerEnforced`, `BucketOwnerPreferred` or `ObjectWriter` got ${var.object_ownership}"
  }
}

variable "versioning_enabled" {
  description = "Whether to enable bucket versioning"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Destroy all bucket objects prior to destroying the bucket so that the bucket may be cleanly destroyed. This will cause irreversible data loss!"
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "The ARN of a KMS CMK with which to encrypt the bucket contents. If omitted, default S3 SSE is used"
  type        = string
  default     = ""
}

variable "bucket_policy_documents" {
  description = "List of iam policy documents to apply to the bucket. Will be merged with default policy documents enforcing HTTPS and SSE"
  type        = list(string)
  default     = []
}

variable "logging_bucket_name" {
  description = "The name of another S3 bucket into which to write access logs for this bucket. If omitted, access logging is not enabled"
  type        = string
  default     = ""
}

variable "is_logging_bucket" {
  description = "Whether this bucket is intended to be an access logging bucket. Enables the 'log-delivery-write' ACL if true"
  type        = bool
  default     = false
}

variable "lifecycle_configuration" {
  description = "Simple bucket object lifecycle configuration with configurable expiry time. If needs are more complicated, use the module output `id` to attach your own configuration"
  type = object({
    enabled         = bool
    expiration_days = optional(number, 30)
  })
  default = {
    enabled         = true
    expiration_days = 30
  }

  validation {
    condition     = var.lifecycle_configuration.expiration_days > 0
    error_message = "expiration_days must be a non-zero positive integer"
  }
}
