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

variable "heroku_user_arn" {
  type        = string
  description = "The name of the Heroku API user who will have write access to the bucket."
}

variable "log_bucket_name" {
  type        = string
  description = "The name of the log bucket."
}

variable "log_bucket_owner_id" {
  type        = string
  description = "The ID of the aws_canonical_user_id who owns the log bucket."
}
