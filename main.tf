resource "aws_s3_bucket" "this" {
  region        = var.region == "" ? data.aws_region.current.region : var.region
  bucket        = var.name
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = var.object_ownership
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning#versioning_configuration
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count = var.kms_key_arn == "" ? 0 : 1

  bucket = aws_s3_bucket.this.id

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.actual_bucket_policy.json
}

resource "aws_s3_bucket_logging" "this" {
  count = var.logging_bucket_arn == "" ? 0 : 1

  bucket = aws_s3_bucket.this.id

  target_bucket = var.logging_bucket_arn
  target_prefix = "logs/s3/${var.name}/"
  target_object_key_format {
    partitioned_prefix {
      partition_date_source = "EventTime"
    }
  }
}

resource "aws_s3_bucket_acl" "log_delivery" {
  count      = var.is_logging_bucket ? 1 : 0
  depends_on = [aws_s3_bucket_ownership_controls.this]

  bucket = aws_s3_bucket.this.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = var.lifecycle_configuration.enabled ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "expire-after-${var.lifecycle_configuration.expiration_days}-days"
    status = "Enabled"
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    expiration {
      days = var.lifecycle_configuration.expiration_days
    }

    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration#filter
    filter {}
  }
}
