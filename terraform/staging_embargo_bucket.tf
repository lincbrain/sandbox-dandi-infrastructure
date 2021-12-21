resource "aws_s3_bucket" "api_staging_embargo_dandisets_bucket" {
  provider = aws.sponsored

  bucket = "dandi-api-staging-embargo-dandisets"
  # acl    = "private"

  cors_rule {
    allowed_origins = [
      "*",
    ]
    allowed_methods = [
      "HEAD",
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
    target_bucket = aws_s3_bucket.api_staging_embargo_dandisets_bucket_logs.id
  }

  versioning {
    enabled = false
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_ownership_controls" "api_staging_embargo_dandisets_bucket" {
  bucket = aws_s3_bucket.api_staging_embargo_dandisets_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket" "api_staging_embargo_dandisets_bucket_logs" {
  provider = aws.sponsored

  bucket = "dandi-api-staging-embargo-dandisets-logs"

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
    id   = data.aws_canonical_user_id.sponsored_account.id
    permissions = [
      "FULL_CONTROL",
    ]
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_policy" "api_staging_embargo_dandisets_bucket" {
  provider = aws.sponsored

  bucket = aws_s3_bucket.api_staging_embargo_dandisets_bucket.id
  policy = data.aws_iam_policy_document.api_staging_embargo_dandisets_bucket.json
}

data "aws_iam_policy_document" "api_staging_embargo_dandisets_bucket" {
  version = "2008-10-17"

  statement {
    sid = "dandi-api-staging"
    principals {
      type        = "AWS"
      identifiers = [data.aws_iam_user.api_staging.arn]
    }
    actions = [
      "s3:*",
    ]
    resources = [
      "${aws_s3_bucket.api_staging_embargo_dandisets_bucket.arn}/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    sid = "dandi-api-staging-delete"
    principals {
      type        = "AWS"
      identifiers = [data.aws_iam_user.api_staging.arn]
    }
    actions = [
      "s3:Delete*",
    ]
    resources = [
      "${aws_s3_bucket.api_staging_embargo_dandisets_bucket.arn}/*",
    ]
  }
}
