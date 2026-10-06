resource "aws_iam_policy" "permeon_validation" {
  name = "permeon-validation-only"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole",
          "s3:DeleteObject"
        ]
        Resource = "*"
      }
    ]
  })
}
