resource "aws_s3_bucket" "sponsored_embargo_bucket" {
  provider = aws.sponsored

  bucket = "dandiarchive-embargo"
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
    # Dumping all logs into the same bucket
    target_bucket = aws_s3_bucket.sponsored_embargo_bucket_logs.id
  }

  versioning {
    enabled = false
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_ownership_controls" "sponsored_embargo_bucket" {
  bucket = aws_s3_bucket.sponsored_embargo_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket" "sponsored_embargo_bucket_logs" {
  provider = aws.sponsored

  bucket = "dandiarchive-embargo-logs"

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

resource "aws_s3_bucket_policy" "sponsored_embargo_bucket" {
  provider = aws.sponsored

  bucket = aws_s3_bucket.sponsored_embargo_bucket.id
  policy = data.aws_iam_policy_document.sponsored_embargo_bucket.json
}

data "aws_iam_policy_document" "sponsored_embargo_bucket" {
  version = "2008-10-17"

  statement {
    sid = "dandi-api"
    principals {
      type        = "AWS"
      identifiers = [data.aws_iam_user.api.arn]
    }
    actions = [
      "s3:*",
    ]
    resources = [
      "${aws_s3_bucket.sponsored_embargo_bucket.arn}/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}
