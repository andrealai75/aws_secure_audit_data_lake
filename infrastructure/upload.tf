resource "aws_s3_object" "upload_ticket_sales" {
  bucket = aws_s3_bucket.secure_audit_data_lake.id

  # Target S3 key path mapped inside your data lake prefix
  key = "raw-logs/ticket_sales.csv"

  # Relative path pointing straight to your file location
  source = "${path.module}/data/ticket_sales.csv"

  # Standard MIME type handling for plain table files
  content_type = "text/csv"

  # MD5 tracking mechanism prevents redundant uploads
  source_hash = filemd5("${path.module}/data/ticket_sales.csv")

  # Enforce strict build sequencing
  depends_on = [
    aws_s3_bucket_server_side_encryption_configuration.data_lake_crypto,
    aws_s3_object.raw_logs_folder
  ]
}
