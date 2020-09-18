data "heroku_team" "publish_heroku" {
  name = "dandi"
}

module "django" {
  source = "girder/django/heroku"
  version = "0.5.0"

  project_slug = "dandi-publish"
  heroku_team_name = data.heroku_team.publish_heroku.name
  route53_zone_id = aws_route53_zone.dandi.zone_id
  subdomain_name = "publish"

  django_cors_origin_whitelist = ["https://gui.dandiarchive.org"]
  django_cors_origin_regex_whitelist = ["^https:\\/\\/[0-9a-z\\-]+--gui-dandiarchive-org\\.netlify\\.app$"]

  additional_django_vars = {
    DJANGO_DANDI_DANDISETS_BUCKET_NAME = aws_s3_bucket.publish_dandisets.id
    DJANGO_DANDI_GIRDER_API_URL  = "https://girder.dandiarchive.org/api/v1"
    DJANGO_SENTRY_DSN = "https://4bd48b5174ea4b42a130e63ebe3d60d2@o308436.ingest.sentry.io/5266078"
  }
  additional_sensitive_django_vars = {
    DJANGO_DANDI_GIRDER_API_KEY = var.girder_api_key
  }
}

resource "aws_s3_bucket" "publish_dandisets" {
  bucket = "dandiarchive-publish-testing"
  acl    = "private"
}

resource "aws_iam_user_policy" "publish_dandisets_bucket" {
  user   = module.django.iam_user_id
  name   = "dandi-publish-dandiset-bucket"
  policy = data.aws_iam_policy_document.publish_dandisets_bucket.json
}

data "aws_iam_policy_document" "publish_dandisets_bucket" {
  statement {
    actions = [
      # TODO Figure out minimal set of permissions django storages needs for S3
      "s3:*",
    ]
    resources = [
      aws_s3_bucket.publish_dandisets.arn,
      "${aws_s3_bucket.publish_dandisets.arn}/*",
    ]
  }
}
