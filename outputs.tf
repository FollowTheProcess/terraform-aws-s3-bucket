output "id" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.this.id
}

output "arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.this.arn
}

output "bucket_domain_name" {
  description = "Bucket domain name, will be of format `bucketname.s3.amazonaws.com`"
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "The bucket region-specific domain name e.g. for a CloudFront S3 origin"
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}
