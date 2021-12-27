# variable "aws_provider" {
#   # type        = string //??
#   description = "The AWS provider."
# }

variable "bucket_name" {
  type        = string
  description = "The name of the bucket."
}

variable "versioning" {
  type        = bool
  description = "Whether or not versioning should be enabled on the bucket."
}

variable "heroku_user" {
  description = "The Heroku API IAM user who will have write access to the bucket."
}

variable "log_bucket_name" {
  type        = string
  description = "The name of the log bucket."
}
