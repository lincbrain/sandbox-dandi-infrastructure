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

variable "log_bucket_name" {
  type        = string
  description = "The name of the log bucket."
}

variable "log_bucket_owner_id" {
  type        = string
  description = "The ID of the aws_canonical_user_id who owns the log bucket."
}

variable "policy_json" {
  type        = string
  description = "The JSON for the policy document. This should be generated from an aws_iam_policy_document."
}
