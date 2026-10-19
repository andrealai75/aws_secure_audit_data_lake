locals {
  region         = "eu-west-1"
  account_id     = data.aws_caller_identity.current.account_id
  s3_bucket_name = "${local.account_id}-${local.region}-secure-audit-data-lake"
  kms_key_alias  = "alias/secure-audit-data-lake"
}
