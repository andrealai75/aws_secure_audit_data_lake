# 1. Create the AWS Glue Catalog Database
resource "aws_glue_catalog_database" "audit_db" {
  name         = "audit_db"
  description  = "Secure database for cataloging ticket audit logs"
  catalog_id   = data.aws_caller_identity.current.account_id
  location_uri = "s3://${aws_s3_bucket.secure_audit_data_lake.bucket}/raw-logs/"
}
