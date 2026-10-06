resource "aws_iam_policy" "permeon_validation" {
  name = "permeon-validation-only"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:GetObject"
        Resource = "arn:aws:s3:::example-bucket/*"
      }
    ]
  })
}
