resource "aws_lakeformation_data_lake_settings" "admin_settings" {
  admins = [data.aws_iam_session_context.current.arn]
}

resource "aws_lakeformation_resource" "data_lake_s3_registration" {
  arn      = aws_s3_bucket.secure_audit_data_lake.arn
  role_arn = aws_iam_role.lake_formation_service_role.arn
}
