data "aws_caller_identity" "sponsored_account" {
  provider = aws
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "dandiset_bucket" {

  bucket = var.bucket_name

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "dandiset_bucket" {
  bucket = aws_s3_bucket.dandiset_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_cors_configuration" "dandiset_bucket" {
  bucket = aws_s3_bucket.dandiset_bucket.id

  cors_rule {
    allowed_origins = [
      "*",
    ]
    allowed_methods = [
      "PUT",
      "POST",
      "GET",
      "HEAD",
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
}

resource "aws_s3_bucket_logging" "dandiset_bucket" {
  bucket = aws_s3_bucket.dandiset_bucket.id

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = ""
}

resource "aws_s3_bucket_versioning" "dandiset_bucket" {
  count = var.versioning ? 1 : 0

  bucket = aws_s3_bucket.dandiset_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "dandiset_bucket" {
  bucket = aws_s3_bucket.dandiset_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# resource "aws_s3_bucket_acl" "dandiset_bucket" {
#   depends_on = [aws_s3_bucket_ownership_controls.dandiset_bucket]
#
#   bucket = aws_s3_bucket.dandiset_bucket.id
#
#   // Public access is granted via a bucket policy, not a canned ACL
#   acl = "private"
# }

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
    for_each = (var.allow_cross_account_heroku_put_object || var.allow_heroku_put_object) ? [1] : []
    content {

      resources = [
        "${aws_s3_bucket.dandiset_bucket.arn}",
        "${aws_s3_bucket.dandiset_bucket.arn}/*",
      ]

      actions = ["s3:PutObject", "s3:PutObjectTagging"]
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

# resource "aws_s3_bucket_policy" "dandiset_bucket_policy" {
#   provider = aws
#
#   bucket = aws_s3_bucket.dandiset_bucket.id
#   policy = data.aws_iam_policy_document.dandiset_bucket_policy.json
# }

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

  # Disallow access to embargoed objects, unless using the heroku user arn
  dynamic "statement" {
    for_each = var.public ? [1] : []

    content {
      effect = "Deny"
      principals {
        identifiers = ["*"]
        type        = "*"
      }
      actions = ["s3:*"]
      resources = [
        "${aws_s3_bucket.dandiset_bucket.arn}/*",
      ]
      condition {
        test     = "StringEquals"
        variable = "s3:ExistingObjectTag/embargoed"
        values   = ["true"]
      }
      condition {
        test     = "ArnNotEquals"
        variable = "aws:PrincipalArn"
        values   = [var.heroku_user.arn]
      }
    }
  }

  dynamic "statement" {
    for_each = var.allow_cross_account_heroku_put_object ? [1] : []

    content {
      sid = "S3PolicyStmt-DO-NOT-MODIFY-1569973164923"
      principals {
        identifiers = ["s3.amazonaws.com"]
        type        = "Service"
      }
      actions = [
        "s3:PutObject",
      ]
      resources = [
        "${aws_s3_bucket.dandiset_bucket.arn}/*",
      ]
      condition {
        test     = "StringEquals"
        variable = "aws:SourceAccount"
        values   = [data.aws_caller_identity.sponsored_account.account_id]
      }
      condition {
        test     = "StringEquals"
        variable = "s3:x-amz-acl"
        values   = ["bucket-owner-full-control"]
      }
      condition {
        test     = "ArnLike"
        variable = "aws:SourceArn"
        values   = [aws_s3_bucket.dandiset_bucket.arn]
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

  dynamic "statement" {
    for_each = var.allow_cross_account_heroku_put_object ? [1] : []
    content {
      resources = [
        "${aws_s3_bucket.dandiset_bucket.arn}",
        "${aws_s3_bucket.dandiset_bucket.arn}/*",
      ]

      actions = ["s3:PutObjectTagging"]

      principals {
        type        = "AWS"
        identifiers = [var.heroku_user.arn]
      }
    }
  }

  dynamic "statement" {
    for_each = var.trailing_delete ? [1] : []

    content {
      sid = "PreventDeletionOfObjectVersions"

      resources = [
        "${aws_s3_bucket.dandiset_bucket.arn}/*"
      ]

      actions = [
        "s3:DeleteObjectVersion",
      ]

      effect = "Deny"

      principals {
        identifiers = ["*"]
        type        = "*"
      }
    }
  }
}


# S3 lifecycle policy that permanently deletes objects with delete markers
# after 30 days. Note, this only applies to objects with the `blobs/` prefix.
resource "aws_s3_bucket_lifecycle_configuration" "expire_deleted_objects" {
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.dandiset_bucket]

  count = var.trailing_delete ? 1 : 0

  bucket = aws_s3_bucket.dandiset_bucket.id

  # Based on https://docs.aws.amazon.com/AmazonS3/latest/userguide/lifecycle-configuration-examples.html#lifecycle-config-conceptual-ex7
  rule {
    id = "ExpireOldDeleteMarkers"
    filter {
      # We only want to expire objects with the `blobs/` prefix, i.e. Asset Blobs.
      # Other objects in this bucket are not subject to this lifecycle policy.
      prefix = "blobs/"
    }

    # Expire objects with delete markers after 30 days
    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    # Also delete any delete markers associated with the expired object
    expiration {
      expired_object_delete_marker = true
    }

    status = "Enabled"
  }
}
