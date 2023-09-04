output "api-execution-arn" {
  value = aws_api_gateway_rest_api.enrollment-api.execution_arn
}

output "invoke-url" {
  value = aws_api_gateway_deployment.api-deployment.invoke_url
}
