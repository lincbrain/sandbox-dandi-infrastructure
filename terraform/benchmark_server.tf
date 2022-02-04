
module "api_benchmark" {
  source  = "girder/django/heroku"
  version = "0.9.0"

  project_slug     = "dandi-api-benchmark"
  heroku_team_name = data.heroku_team.dandi.name
  route53_zone_id  = aws_route53_zone.dandi.zone_id
  subdomain_name   = "api-benchmark"

  heroku_web_dyno_size    = "hobby"
  heroku_worker_dyno_size = "hobby"
  heroku_postgresql_plan  = "hobby-basic"
  heroku_cloudamqp_plan   = "tiger"
  heroku_papertrail_plan  = "fixa"

  heroku_web_dyno_quantity    = 1
  heroku_worker_dyno_quantity = 1

  django_default_from_email          = "admin@api-benchmark.dandiarchive.org"
  django_cors_origin_whitelist       = ["https://gui-staging.dandiarchive.org"]
  django_cors_origin_regex_whitelist = ["^https:\\/\\/[0-9a-z\\-]+--gui-dandiarchive-org\\.netlify\\.app$"]

  additional_django_vars = {
    DJANGO_CONFIGURATION                         = "HerokuStagingConfiguration"
    DJANGO_DANDI_DANDISETS_BUCKET_NAME           = module.benchmark_bucket.bucket_name
    DJANGO_DANDI_DANDISETS_BUCKET_PREFIX         = ""
    DJANGO_DANDI_DANDISETS_EMBARGO_BUCKET_NAME   = module.benchmark_embargo_bucket.bucket_name
    DJANGO_DANDI_DANDISETS_EMBARGO_BUCKET_PREFIX = ""
    DJANGO_DANDI_DOI_API_URL                     = "https://api.test.datacite.org/dois"
    DJANGO_DANDI_DOI_API_USER                    = "dartlib.dandi"
    DJANGO_DANDI_DOI_API_PREFIX                  = "10.80507"
    DJANGO_DANDI_DOI_PUBLISH                     = "false"
    DJANGO_SENTRY_DSN                            = "https://4bd48b5174ea4b42a130e63ebe3d60d2@o308436.ingest.sentry.io/5266078"
    DJANGO_SENTRY_ENVIRONMENT                    = "benchmark"
    DJANGO_CELERY_WORKER_CONCURRENCY             = "2"
    DJANGO_DANDI_WEB_APP_URL                     = "https://gui-staging.dandiarchive.org"
    DJANGO_DANDI_API_URL                         = "https://api-staging.dandiarchive.org"
  }
  additional_sensitive_django_vars = {
    DJANGO_DANDI_DOI_API_PASSWORD = var.test_doi_api_password
  }
}
resource "heroku_formation" "benchmark_checksum_worker" {
  app      = module.api_benchmark.heroku_app_id
  type     = "checksum-worker"
  size     = "hobby"
  quantity = 1
}

data "aws_iam_user" "api_benchmark" {
  user_name = module.api_benchmark.heroku_iam_user_id
}

module "benchmark_bucket" {
  source          = "./modules/dandiset_bucket"
  bucket_name     = "dandi-api-benchmark-dandisets"
  versioning      = false
  heroku_user     = data.aws_iam_user.api_benchmark
  log_bucket_name = "dandi-api-benchmark-dandisets-logs"
  providers = {
    aws         = aws
    aws.project = aws
  }
}

module "benchmark_embargo_bucket" {
  source          = "./modules/dandiset_bucket"
  bucket_name     = "dandi-api-benchmark-embargo-dandisets"
  versioning      = false
  heroku_user     = data.aws_iam_user.api_benchmark
  log_bucket_name = "dandi-api-benchmark-embargo-dandisets-logs"
  providers = {
    aws         = aws
    aws.project = aws
  }
}
