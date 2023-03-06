module "staging_dandiset_bucket" {
  source                  = "./modules/dandiset_bucket"
  bucket_name             = "dandi-api-staging-dandisets"
  public                  = true
  versioning              = true
  allow_heroku_put_object = true
  heroku_user             = data.aws_iam_user.api_staging
  log_bucket_name         = "dandi-api-staging-dandiset-logs"
  providers = {
    aws         = aws
    aws.project = aws
  }
}



moved {
  from = aws_s3_bucket.api_staging_dandisets_bucket
  to   = module.staging_dandiset_bucket.aws_s3_bucket.dandiset_bucket
}

moved {
  from = aws_s3_bucket_ownership_controls.api_staging_dandisets_bucket
  to   = module.staging_dandiset_bucket.aws_s3_bucket_ownership_controls.dandiset_bucket
}

moved {
  from = aws_s3_bucket.api_staging_dandisets_bucket_logs
  to   = module.staging_dandiset_bucket.aws_s3_bucket.log_bucket
}

moved {
  from = aws_s3_bucket_policy.api_staging_dandisets_bucket
  to   = module.staging_dandiset_bucket.aws_s3_bucket_policy.dandiset_bucket_policy
}

module "staging_embargo_bucket" {
  source          = "./modules/dandiset_bucket"
  bucket_name     = "dandi-api-staging-embargo-dandisets"
  versioning      = false
  heroku_user     = data.aws_iam_user.api_staging
  log_bucket_name = "dandi-api-staging-embargo-dandisets-logs"
  providers = {
    aws         = aws
    aws.project = aws
  }
}
