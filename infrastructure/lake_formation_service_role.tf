# 1. Trust Policy: Allows the Lake Formation Service to assume this role
resource "aws_iam_role" "lake_formation_service_role" {
  name = "secure-data-lake-lf-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lakeformation.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:SetContext"
        ]
      }
    ]
  })
}

# 2. Permissions Policy: Grant access to your exact S3 bucket and KMS Key
resource "aws_iam_role_policy" "lake_formation_service_policy" {
  name = "lake-formation-s3-kms-access"
  role = aws_iam_role.lake_formation_service_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3DataLakeAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.secure_audit_data_lake.arn,
          "${aws_s3_bucket.secure_audit_data_lake.arn}/*"
        ]
      },
      {
        Sid    = "KMSDecryptAccess"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = aws_kms_key.secure-audit-data-lake.arn
      }
    ]
  })
}
