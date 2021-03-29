
resource "aws_iam_policy" "sponsored_writers" {
  provider = aws.sponsored

  name        = "writers"
  description = "Allows writing and deleting objects"
  policy      = data.aws_iam_policy_document.sponsored_writers.json
}

data "aws_iam_policy_document" "sponsored_writers" {
  version = "2012-10-17"
  statement {
    sid = "VisualEditor0"
    actions = [
      "s3:DeleteObjectTagging",
      "s3:ListBucketByTags",
      "s3:ListBucketMultipartUploads",
      "s3:GetBucketTagging",
      "s3:ListBucketVersions",
      "s3:PutObjectVersionTagging",
      "s3:ListBucket",
      "s3:DeleteObjectVersionTagging",
      "s3:GetBucketVersioning",
      "s3:GetObjectVersionTorrent",
      "s3:PutObject",
      "s3:GetObject",
      "s3:PutBucketTagging",
      "s3:GetObjectTagging",
      "s3:PutObjectTagging",
      "s3:DeleteObject",
      "s3:GetBucketLocation",
      "s3:GetObjectVersion",
    ]
    resources = [
      "${aws_s3_bucket.sponsored_bucket.arn}/*",
      aws_s3_bucket.sponsored_bucket.arn,
    ]
  }
}

resource "aws_iam_role" "sponsored_dandi_writer" {
  provider = aws.sponsored

  name               = "dandi-writer"
  description        = "external instance write access to the public dataset"
  assume_role_policy = data.aws_iam_policy_document.sponsored_dandi_writer.json
}

data "aws_iam_policy_document" "sponsored_dandi_writer" {
  version = "2012-10-17"
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.project_account.account_id}:root",
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "sponsored_dandi_writer_attach" {
  provider = aws.sponsored

  role       = aws_iam_role.sponsored_dandi_writer.name
  policy_arn = aws_iam_policy.sponsored_writers.arn
}

resource "aws_iam_group" "sponsored_writers" {
  provider = aws.sponsored

  name = "writers"
}

resource "aws_iam_group_policy_attachment" "sponsored_writers_attach" {
  provider = aws.sponsored

  group      = aws_iam_group.sponsored_writers.name
  policy_arn = aws_iam_policy.sponsored_writers.arn
}

resource "aws_iam_user" "sponsored_dandi_write_bot" {
  provider = aws.sponsored

  name = "dandi-write-bot"
}

resource "aws_iam_user_group_membership" "sponsored_dandi_write_bot_membership" {
  provider = aws.sponsored

  user   = aws_iam_user.sponsored_dandi_write_bot.name
  groups = [aws_iam_group.sponsored_writers.name]
}
