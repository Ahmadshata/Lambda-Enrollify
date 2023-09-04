output "auth-fun-invoke-arn" {
  value = aws_lambda_function.auth.invoke_arn
}

output "manipulator-fun-invoke-arn" {
  value = aws_lambda_function.manipulator.invoke_arn
}
