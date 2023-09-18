# Staging bucket
import {
  to = module.staging_dandiset_bucket.aws_s3_bucket_cors_configuration.dandiset_bucket
  id = "dandi-api-staging-dandisets"
}
import {
  to = module.staging_dandiset_bucket.aws_s3_bucket_logging.dandiset_bucket
  id = "dandi-api-staging-dandisets"
}
import {
  to = module.staging_dandiset_bucket.aws_s3_bucket_versioning.dandiset_bucket[0]
  id = "dandi-api-staging-dandisets"
}
import {
  to = module.staging_dandiset_bucket.aws_s3_bucket_ownership_controls.dandiset_bucket
  id = "dandi-api-staging-dandisets"
}
import {
  to = module.staging_dandiset_bucket.aws_s3_bucket_server_side_encryption_configuration.dandiset_bucket
  id = "dandi-api-staging-dandisets"
}
import {
  to = module.staging_dandiset_bucket.aws_s3_bucket_acl.dandiset_bucket
  id = "dandi-api-staging-dandisets"
}
import {
  to = module.staging_dandiset_bucket.aws_s3_bucket_server_side_encryption_configuration.log_bucket
  id = "dandi-api-staging-dandiset-logs"
}

# Staging (embargoed) bucket
import {
  to = module.staging_embargo_bucket.aws_s3_bucket_cors_configuration.dandiset_bucket
  id = "dandi-api-staging-embargo-dandisets"
}
import {
  to = module.staging_embargo_bucket.aws_s3_bucket_logging.dandiset_bucket
  id = "dandi-api-staging-embargo-dandisets"
}
import {
  to = module.staging_embargo_bucket.aws_s3_bucket_ownership_controls.dandiset_bucket
  id = "dandi-api-staging-embargo-dandisets"
}
import {
  to = module.staging_embargo_bucket.aws_s3_bucket_server_side_encryption_configuration.dandiset_bucket
  id = "dandi-api-staging-embargo-dandisets"
}
import {
  to = module.staging_embargo_bucket.aws_s3_bucket_acl.dandiset_bucket
  id = "dandi-api-staging-embargo-dandisets"
}
import {
  to = module.staging_embargo_bucket.aws_s3_bucket_server_side_encryption_configuration.log_bucket
  id = "dandi-api-staging-embargo-dandisets-logs"
}

# Sponsored bucket
import {
  to = module.sponsored_dandiset_bucket.aws_s3_bucket_cors_configuration.dandiset_bucket
  id = "dandiarchive"
}
import {
  to = module.sponsored_dandiset_bucket.aws_s3_bucket_logging.dandiset_bucket
  id = "dandiarchive"
}
import {
  to = module.sponsored_dandiset_bucket.aws_s3_bucket_versioning.dandiset_bucket[0]
  id = "dandiarchive"
}
import {
  to = module.sponsored_dandiset_bucket.aws_s3_bucket_ownership_controls.dandiset_bucket
  id = "dandiarchive"
}
import {
  to = module.sponsored_dandiset_bucket.aws_s3_bucket_server_side_encryption_configuration.dandiset_bucket
  id = "dandiarchive"
}
import {
  to = module.sponsored_dandiset_bucket.aws_s3_bucket_acl.dandiset_bucket
  id = "dandiarchive"
}
import {
  to = module.sponsored_dandiset_bucket.aws_s3_bucket_server_side_encryption_configuration.log_bucket
  id = "dandiarchive-logs"
}

# Sponsored (embargoed) bucket
import {
  to = module.sponsored_embargo_bucket.aws_s3_bucket_cors_configuration.dandiset_bucket
  id = "dandiarchive-embargo"
}
import {
  to = module.sponsored_embargo_bucket.aws_s3_bucket_logging.dandiset_bucket
  id = "dandiarchive-embargo"
}
import {
  to = module.sponsored_embargo_bucket.aws_s3_bucket_ownership_controls.dandiset_bucket
  id = "dandiarchive-embargo"
}
import {
  to = module.sponsored_embargo_bucket.aws_s3_bucket_server_side_encryption_configuration.dandiset_bucket
  id = "dandiarchive-embargo"
}
import {
  to = module.sponsored_embargo_bucket.aws_s3_bucket_acl.dandiset_bucket
  id = "dandiarchive-embargo"
}
import {
  to = module.sponsored_embargo_bucket.aws_s3_bucket_server_side_encryption_configuration.log_bucket
  id = "dandiarchive-embargo-logs"
}
