output "bucket_name" {
  value       = aws_s3_bucket.dandiset_bucket.id
  description = "The S3 bucket name."
}

output "log_bucket_name" {
  value       = aws_s3_bucket.log_bucket.id
  description = "The S3 log bucket name."
}

output "bucket_arn" {
  value       = aws_s3_bucket.dandiset_bucket.arn
  description = "The S3 bucket ARN."
}
