# See api.tf for the definition of the production app


module "api_staging" {
  source  = "girder/django/heroku"
  version = "0.9.0"

  project_slug     = "dandi-api-staging"
  heroku_team_name = data.heroku_team.dandi.name
  route53_zone_id  = aws_route53_zone.dandi.zone_id
  subdomain_name   = "api-staging"

  heroku_postgresql_plan = "hobby-basic"

  heroku_web_dyno_quantity    = 1
  heroku_worker_dyno_quantity = 1

  django_default_from_email          = "admin@api-staging.dandiarchive.org"
  django_cors_origin_whitelist       = ["https://gui-staging.dandiarchive.org"]
  django_cors_origin_regex_whitelist = ["^https:\\/\\/[0-9a-z\\-]+--gui-dandiarchive-org\\.netlify\\.app$"]

  additional_django_vars = {
    DJANGO_CONFIGURATION                 = "HerokuStagingConfiguration"
    DJANGO_DANDI_DANDISETS_BUCKET_NAME   = aws_s3_bucket.api_staging_dandisets_bucket.id
    DJANGO_DANDI_DANDISETS_BUCKET_PREFIX = ""
    DJANGO_DANDI_SCHEMA_VERSION          = "0.5.1"
    DJANGO_DANDI_DOI_API_URL             = "https://api.test.datacite.org/dois"
    DJANGO_DANDI_DOI_API_USER            = "dartlib.dandi"
    DJANGO_DANDI_DOI_API_PREFIX          = "10.80507"
    DJANGO_DANDI_DOI_PUBLISH             = "false"
    DJANGO_SENTRY_DSN                    = "https://4bd48b5174ea4b42a130e63ebe3d60d2@o308436.ingest.sentry.io/5266078"
    DJANGO_SENTRY_ENVIRONMENT            = "staging"
  }
  additional_sensitive_django_vars = {
    DJANGO_DANDI_DOI_API_PASSWORD = var.test_doi_api_password
  }
}

data "aws_iam_user" "api_staging" {
  user_name = module.api_staging.heroku_iam_user_id
}

resource "aws_s3_bucket" "api_staging_dandisets_bucket" {
  bucket = "dandi-api-staging-dandisets"
  acl    = "private"
}

resource "aws_s3_bucket_policy" "api_staging_dandisets_bucket" {
  bucket = aws_s3_bucket.api_staging_dandisets_bucket.id
  policy = data.aws_iam_policy_document.api_staging_dandisets_bucket.json
}

data "aws_iam_policy_document" "api_staging_dandisets_bucket" {
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
      "${aws_s3_bucket.api_staging_dandisets_bucket.arn}/*",
    ]
  }
}


resource "heroku_pipeline" "dandi_pipeline" {
  name = "dandi-pipeline"

  owner {
    id   = data.heroku_team.dandi.id
    type = "team"
  }
}

resource "heroku_pipeline_coupling" "staging" {
  app      = module.api_staging.heroku_app_id
  pipeline = heroku_pipeline.dandi_pipeline.id
  stage    = "staging"
}

resource "heroku_pipeline_coupling" "production" {
  app      = module.api.heroku_app_id
  pipeline = heroku_pipeline.dandi_pipeline.id
  stage    = "production"
}
