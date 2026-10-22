# 1. Personas Storage: Create the Audit Admin User
resource "aws_iam_user" "audit_admin" {
  name          = "AuditAdmin"
  force_destroy = true
}

# 2. Personas Storage: Create the Data Analyst User
resource "aws_iam_user" "data_analyst" {
  name          = "DataAnalyst"
  force_destroy = true
}

# 3. Base Managed Policy Attachment for Athena Access
# Both users need basic access to use the Athena service and list the catalog
resource "aws_iam_policy" "athena_base_access" {
  name        = "secure-data-lake-athena-base-access"
  description = "Minimal baseline permissions required to log into and use Amazon Athena"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AthenaServiceAccess"
        Effect = "Allow"
        Action = [
          "athena:Get*",
          "athena:List*",
          "athena:StartQueryExecution",
          "athena:StopQueryExecution"
        ]
        Resource = "*"
      },
      {
        Sid    = "GlueCatalogReadBaseline"
        Effect = "Allow"
        Action = [
          "glue:GetDatabase",
          "glue:GetDatabases",
          "glue:GetTable",
          "glue:GetTables"
        ]
        Resource = "*"
      },
      {
        Sid      = "LakeFormationDataAccess"
        Effect   = "Allow"
        Action   = "lakeformation:GetDataAccess"
        Resource = "*"
      },
      {
        Sid      = "AthenaResultsBucketLocation"
        Effect   = "Allow"
        Action   = "s3:GetBucketLocation"
        Resource = aws_s3_bucket.secure_audit_data_lake.arn
      },
      {
        Sid      = "AthenaResultsBucketListing"
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = aws_s3_bucket.secure_audit_data_lake.arn
        Condition = {
          StringLike = {
            "s3:prefix" = [
              "athena-results",
              "athena-results/*"
            ]
          }
        }
      },
      {
        Sid    = "AthenaResultsObjectAccess"
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetObject",
          "s3:ListMultipartUploadParts",
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.secure_audit_data_lake.arn}/athena-results/*"
      },
      {
        Sid    = "AthenaResultsKmsAccess"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey"
        ]
        Resource = aws_kms_key.secure-audit-data-lake.arn
      }
    ]
  })
}

# Attach the base Athena policy to both users
resource "aws_iam_user_policy_attachment" "admin_base" {
  user       = aws_iam_user.audit_admin.name
  policy_arn = aws_iam_policy.athena_base_access.arn
}

resource "aws_iam_user_policy_attachment" "analyst_base" {
  user       = aws_iam_user.data_analyst.name
  policy_arn = aws_iam_policy.athena_base_access.arn
}
