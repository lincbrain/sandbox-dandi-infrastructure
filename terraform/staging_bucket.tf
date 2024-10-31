module "staging_dandiset_bucket" {
  source                  = "./modules/dandiset_bucket"
  bucket_name             = "sandbox-dandi-api-staging-dandisets"
  public                  = true
  versioning              = true
  trailing_delete         = true
  allow_heroku_put_object = true
  heroku_user             = data.aws_iam_user.api_staging
  log_bucket_name         = "sandbox-dandi-api-staging-dandiset-logs"
  providers = {
    aws         = aws
    aws.project = aws
  }
}

module "staging_embargo_bucket" {
  source          = "./modules/dandiset_bucket"
  bucket_name     = "sandbox-dandi-api-staging-embargo-dandisets"
  versioning      = false
  trailing_delete = false
  heroku_user     = data.aws_iam_user.api_staging
  log_bucket_name = "sandbox-dandi-api-staging-embargo-dandisets-logs"
  providers = {
    aws         = aws
    aws.project = aws
  }
}
