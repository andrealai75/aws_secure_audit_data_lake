resource "aws_kms_key" "secure-audit-data-lake" {
  description             = "Key for encrypting S3 bucket objects"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-default-1"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow Glue and Athena Service Access"
        Effect = "Allow"
        Principal = {
          Service = [
            "athena.amazonaws.com",
            "glue.amazonaws.com"
          ],
        },
        Action = [
          "kms:DescribeKey",
          "kms:GenerateDataKey",
          "kms:Decrypt"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_kms_alias" "secure-audit-data-lake" {
  name          = local.kms_key_alias
  target_key_id = aws_kms_key.secure-audit-data-lake.key_id
}
