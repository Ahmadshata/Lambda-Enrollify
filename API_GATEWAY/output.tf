output "api-execution-arn" {
  value = aws_api_gateway_rest_api.enrollment-api.execution_arn
}

output "invoke-url" {
  value = aws_api_gateway_deployment.api-deployment.invoke_url
}

output "custom-domain-name" {
  value = aws_api_gateway_domain_name.custom-domain.domain_name
}

output "resource-name" {
  value = aws_api_gateway_resource.enrollment-resource.path_part
}

output "api-key-value" {
  value = aws_api_gateway_api_key.enrollment-key.value
}