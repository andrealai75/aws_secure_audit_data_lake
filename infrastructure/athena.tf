resource "aws_athena_workgroup" "secure_audit_workgroup" {
  name          = "secure-audit-workgroup"
  description   = "Serverless query sandbox with enforced encrypted results and scan limits"
  force_destroy = true

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true
    bytes_scanned_cutoff_per_query     = 10485760

    result_configuration {
      output_location = "s3://${aws_s3_bucket.secure_audit_data_lake.bucket}/athena-results/"

      encryption_configuration {
        encryption_option = "SSE_KMS"
        kms_key_arn       = aws_kms_key.secure-audit-data-lake.arn
      }
    }
  }
}