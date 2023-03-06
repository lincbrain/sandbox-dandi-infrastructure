data "aws_canonical_user_id" "log_bucket_owner_account" {}

resource "aws_s3_bucket" "dandiset_bucket" {

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

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "dandiset_bucket" {
  bucket = aws_s3_bucket.dandiset_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket" "log_bucket" {
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
    id   = data.aws_canonical_user_id.log_bucket_owner_account.id
    permissions = [
      "FULL_CONTROL",
    ]
  }

  lifecycle {
    prevent_destroy = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_iam_user_policy" "dandiset_bucket_owner" {
  // The Heroku IAM user will always be in the project account
  provider = aws.project

  name = "${var.bucket_name}-ownership-policy"
  user = var.heroku_user.user_name

  policy = data.aws_iam_policy_document.dandiset_bucket_owner.json
}

data "aws_iam_policy_document" "dandiset_bucket_owner" {
  version = "2008-10-17"

  statement {
    resources = [
      "${aws_s3_bucket.dandiset_bucket.arn}",
      "${aws_s3_bucket.dandiset_bucket.arn}/*",
    ]

    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:Delete*",
    ]
  }

  dynamic "statement" {
    for_each = var.allow_heroku_put_object ? [1] : []
    content {

      resources = [
        "${aws_s3_bucket.dandiset_bucket.arn}",
        "${aws_s3_bucket.dandiset_bucket.arn}/*",
      ]

      actions = ["s3:PutObject"]
    }
  }

  statement {
    resources = [
      "${aws_s3_bucket.dandiset_bucket.arn}",
      "${aws_s3_bucket.dandiset_bucket.arn}/*",
    ]

    actions = ["s3:*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}


resource "aws_s3_bucket_policy" "dandiset_bucket_policy" {
  provider = aws

  bucket = aws_s3_bucket.dandiset_bucket.id
  policy = data.aws_iam_policy_document.dandiset_bucket_policy.json
}

data "aws_iam_policy_document" "dandiset_bucket_policy" {
  version = "2008-10-17"

  dynamic "statement" {
    for_each = var.public ? [1] : []

    content {
      resources = [
        "${aws_s3_bucket.dandiset_bucket.arn}",
        "${aws_s3_bucket.dandiset_bucket.arn}/*",
      ]

      actions = [
        "s3:Get*",
        "s3:List*",
      ]

      principals {
        identifiers = ["*"]
        type        = "*"
      }
    }
  }

  statement {
    resources = [
      "${aws_s3_bucket.dandiset_bucket.arn}",
      "${aws_s3_bucket.dandiset_bucket.arn}/*",
    ]

    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:Delete*",
    ]

    principals {
      type        = "AWS"
      identifiers = [var.heroku_user.arn]
    }
  }

  statement {
    resources = [
      "${aws_s3_bucket.dandiset_bucket.arn}",
      "${aws_s3_bucket.dandiset_bucket.arn}/*",
    ]

    actions = ["s3:*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    principals {
      type        = "AWS"
      identifiers = [var.heroku_user.arn]
    }
  }
}
