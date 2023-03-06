module "sponsored_dandiset_bucket" {
  source                = "./modules/dandiset_bucket"
  bucket_name           = "dandiarchive"
  ownership_policy_name = "dandi-api-sponsored-bucket"
  public                = true
  versioning            = true
  heroku_user           = data.aws_iam_user.api
  log_bucket_name       = "dandiarchive-logs"
  providers = {
    aws         = aws.sponsored
    aws.project = aws
  }
}


moved {
  from = aws_s3_bucket.sponsored_bucket
  to   = module.sponsored_dandiset_bucket.aws_s3_bucket.dandiset_bucket
}

moved {
  from = aws_s3_bucket_ownership_controls.sponsored_bucket
  to   = module.sponsored_dandiset_bucket.aws_s3_bucket_ownership_controls.dandiset_bucket
}

moved {
  from = aws_s3_bucket.sponsored_bucket_logs
  to   = module.sponsored_dandiset_bucket.aws_s3_bucket.log_bucket
}

moved {
  from = aws_s3_bucket_policy.sponsored_bucket
  to   = module.sponsored_dandiset_bucket.aws_s3_bucket_policy.dandiset_bucket_policy
}


module "sponsored_embargo_bucket" {
  source          = "./modules/dandiset_bucket"
  bucket_name     = "dandiarchive-embargo"
  versioning      = false
  heroku_user     = data.aws_iam_user.api
  log_bucket_name = "dandiarchive-embargo-logs"
  providers = {
    aws         = aws.sponsored
    aws.project = aws
  }
}
