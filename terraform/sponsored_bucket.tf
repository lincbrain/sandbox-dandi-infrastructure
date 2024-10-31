# module "sponsored_dandiset_bucket" {
#   source                                = "./modules/dandiset_bucket"
#   bucket_name                           = "dandiarchive"
#   public                                = true
#   versioning                            = true
#   trailing_delete                       = false
#   allow_cross_account_heroku_put_object = true
#   heroku_user                           = data.aws_iam_user.api
#   log_bucket_name                       = "dandiarchive-logs"
#   providers = {
#     aws         = aws.sponsored
#     aws.project = aws
#   }
# }
#
# module "sponsored_embargo_bucket" {
#   source          = "./modules/dandiset_bucket"
#   bucket_name     = "dandiarchive-embargo"
#   versioning      = false
#   trailing_delete = false
#   heroku_user     = data.aws_iam_user.api
#   log_bucket_name = "dandiarchive-embargo-logs"
#   providers = {
#     aws         = aws.sponsored
#     aws.project = aws
#   }
# }
