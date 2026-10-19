resource "aws_s3_bucket" "secure_audit_data_lake" {
  bucket        = local.s3_bucket_name
  force_destroy = true

  tags = {
    Name = "secure-audit-data-lake"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data_lake_crypto" {
  bucket = aws_s3_bucket.secure_audit_data_lake.id

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.secure-audit-data-lake.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "data_lake_privacy" {
  bucket = aws_s3_bucket.secure_audit_data_lake.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "data_lake_enforcement" {
  bucket = aws_s3_bucket.secure_audit_data_lake.id

  depends_on = [aws_s3_bucket_public_access_block.data_lake_privacy]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnforceTLSRequestsOnly"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.secure_audit_data_lake.arn,
          "${aws_s3_bucket.secure_audit_data_lake.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

# 1. Raw Data Ingestion Prefix
resource "aws_s3_object" "raw_logs_folder" {
  bucket       = aws_s3_bucket.secure_audit_data_lake.id
  key          = "raw-logs/"
  content_type = "application/x-directory"

  # Ensures encryption configuration is active before placing objects
  depends_on = [aws_s3_bucket_server_side_encryption_configuration.data_lake_crypto]
}

# 2. Athena Query Execution Results Prefix
resource "aws_s3_object" "athena_results_folder" {
  bucket       = aws_s3_bucket.secure_audit_data_lake.id
  key          = "athena-results/"
  content_type = "application/x-directory"

  depends_on = [aws_s3_bucket_server_side_encryption_configuration.data_lake_crypto]
}
