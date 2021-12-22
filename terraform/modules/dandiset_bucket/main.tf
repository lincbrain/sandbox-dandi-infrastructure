resource "aws_s3_bucket" "dandiset_bucket" {
  # provider = var.aws_provider

  bucket = var.bucket_name
  // Public access is granted via a bucket policy, not a canned ACL
  acl = "private"

  cors_rule {
    allowed_origins = [
      "*",
    ]
    allowed_methods = [
      "PUT",
      "POST",
      "GET",
      "DELETE",
    ]
    allowed_headers = [
      "*"
    ]
    expose_headers = [
      "ETag",
    ]
    max_age_seconds = 3000
  }

  logging {
    target_bucket = aws_s3_bucket.log_bucket.id
  }

  versioning {
    enabled = var.versioning
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_ownership_controls" "dandiset_bucket" {
  bucket = aws_s3_bucket.dandiset_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket" "log_bucket" {
  # provider = var.aws_provider

  bucket = var.log_bucket_name

  grant {
    type = "Group"
    uri  = "http://acs.amazonaws.com/groups/s3/LogDelivery"
    permissions = [
      "READ_ACP",
      "WRITE",
    ]
  }
  grant {
    type = "CanonicalUser"
    id   = var.log_bucket_owner_id
    permissions = [
      "FULL_CONTROL",
    ]
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_policy" "dandiset_bucket" {
  # provider = var.aws_provider

  bucket = aws_s3_bucket.dandiset_bucket.id
  policy = var.policy_json
}
