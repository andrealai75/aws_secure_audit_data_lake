data "aws_caller_identity" "current" {}

# Safely extracts the true IAM User or Role ARN, even if running inside an assumed session
data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}
