data "heroku_team" "dandi" {
  name = "dandi"
}

module "api" {
  source  = "girder/django/heroku"
  version = "0.8.0"

  project_slug     = "dandi-api"
  heroku_team_name = data.heroku_team.dandi.name
  route53_zone_id  = aws_route53_zone.dandi.zone_id
  subdomain_name   = "api"

  heroku_web_dyno_size    = "standard-1x"
  heroku_worker_dyno_size = "standard-2x"
  heroku_postgresql_plan  = "standard-0"
  heroku_cloudamqp_plan   = "squirrel-1"
  heroku_papertrail_plan  = "forsta"

  django_cors_origin_whitelist       = ["https://gui.dandiarchive.org", "https://gui-beta-dandiarchive-org.netlify.app"]
  django_cors_origin_regex_whitelist = ["^https:\\/\\/[0-9a-z\\-]+--gui-dandiarchive-org\\.netlify\\.app$"]

  additional_django_vars = {
    # DJANGO_DANDI_DANDISETS_BUCKET_NAME = aws_s3_bucket.sponsored_bucket.id
    DJANGO_DANDI_DANDISETS_BUCKET_NAME = aws_s3_bucket.api_dandisets_bucket.id
    DJANGO_DANDI_SCHEMA_VERSION        = "0.1.0"
    DJANGO_DANDI_GIRDER_API_URL        = "https://girder.dandiarchive.org/api/v1"
    DJANGO_DANDI_DOI_API_URL           = "https://api.test.datacite.org/dois"
    DJANGO_DANDI_DOI_API_USER          = "dartlib.dandi"
    DJANGO_DANDI_DOI_API_PREFIX        = "10.80507"
    DJANGO_SENTRY_DSN                  = "https://4bd48b5174ea4b42a130e63ebe3d60d2@o308436.ingest.sentry.io/5266078"
  }
  additional_sensitive_django_vars = {
    DJANGO_DANDI_GIRDER_API_KEY   = var.girder_api_key
    DJANGO_DANDI_DOI_API_PASSWORD = var.doi_api_password
  }
}

resource "aws_s3_bucket" "api_dandisets_bucket" {
  bucket = "dandi-api-dandisets-testing"
  acl    = "private"
}

resource "aws_iam_user_policy" "api_dandisets_bucket" {
  user   = module.api.iam_user_id
  name   = "dandi-api-dandiset-bucket"
  policy = data.aws_iam_policy_document.api_dandisets_bucket.json
}

data "aws_iam_policy_document" "api_dandisets_bucket" {
  statement {
    actions = [
      # TODO Figure out minimal set of permissions django storages needs for S3
      "s3:*",
    ]
    resources = [
      aws_s3_bucket.api_dandisets_bucket.arn,
      "${aws_s3_bucket.api_dandisets_bucket.arn}/*",
      aws_s3_bucket.sponsored_bucket.arn,
      "${aws_s3_bucket.sponsored_bucket.arn}/*",
    ]
  }
}

resource "aws_iam_role" "write_public_dataset" {
  name               = "write-public-dataset"
  description        = "Allows EC2 instances to call AWS services on your behalf."
  assume_role_policy = data.aws_iam_policy_document.write_public_dataset.json
  inline_policy {
    name   = "write-public-dataset"
    policy = data.aws_iam_policy_document.write_public_dataset_inline.json
  }
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
  ]
}

data "aws_iam_policy_document" "write_public_dataset" {
  version = "2012-10-17"
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "write_public_dataset_inline" {
  version = "2012-10-17"
  statement {
    actions   = ["sts:AssumeRole"]
    effect    = "Allow"
    resources = [aws_iam_role.sponsored_dandi_writer.arn]
  }
}


resource "aws_iam_role" "dandi_girder" {
  name               = "dandi-girder"
  assume_role_policy = data.aws_iam_policy_document.dandi_girder.json
  inline_policy {
    name   = "write-public-dataset"
    policy = data.aws_iam_policy_document.write_public_dataset_inline.json
  }
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
  ]
}

data "aws_iam_policy_document" "dandi_girder" {
  version = "2012-10-17"
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.project_account.account_id}:user/${module.api.iam_user_id}"]
    }
  }
}
