output "arn" {
  description = "The ARN assigned by AWS to this policy."
  value       = aws_iam_policy.logging_policy.arn
}

output "name" {
  description = "The name of the policy."
  value       = aws_iam_policy.logging_policy.name
}
