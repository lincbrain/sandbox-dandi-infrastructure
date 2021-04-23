# See api.tf for the definition of the production app


module "api_staging" {
  source  = "girder/django/heroku"
  version = "0.9.0"

  project_slug     = "dandi-api-staging"
  heroku_team_name = data.heroku_team.dandi.name
  route53_zone_id  = aws_route53_zone.dandi.zone_id
  subdomain_name   = "api-staging"

  django_cors_origin_whitelist       = ["https://gui-staging.dandiarchive.org"]
  django_cors_origin_regex_whitelist = ["^https:\\/\\/[0-9a-z\\-]+--gui-dandiarchive-org\\.netlify\\.app$"]

  additional_django_vars = {
    DJANGO_DANDI_DANDISETS_BUCKET_NAME   = aws_s3_bucket.api_staging_dandisets_bucket.id
    DJANGO_DANDI_DANDISETS_BUCKET_PREFIX = ""
    DJANGO_DANDI_SCHEMA_VERSION          = "0.3.0"
    DJANGO_DANDI_GIRDER_API_URL          = "https://girder.dandiarchive.org/api/v1"
    DJANGO_DANDI_DOI_API_URL             = "https://api.test.datacite.org/dois"
    DJANGO_DANDI_DOI_API_USER            = "dartlib.dandi"
    DJANGO_DANDI_DOI_API_PREFIX          = "10.80507"
    DJANGO_SENTRY_DSN                    = "https://4bd48b5174ea4b42a130e63ebe3d60d2@o308436.ingest.sentry.io/5266078"
  }
  additional_sensitive_django_vars = {
    DJANGO_DANDI_GIRDER_API_KEY   = var.girder_api_key
    DJANGO_DANDI_DOI_API_PASSWORD = var.doi_api_password
  }
}

resource "aws_s3_bucket" "api_staging_dandisets_bucket" {
  bucket = "dandi-api-staging-dandisets"
  acl    = "private"
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
