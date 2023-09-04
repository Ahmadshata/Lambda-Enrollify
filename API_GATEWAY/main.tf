resource "aws_api_gateway_rest_api" "enrollment-api" {
  name = "enrollment"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "enrollment-resource" {
  rest_api_id = aws_api_gateway_rest_api.enrollment-api.id
  parent_id   = aws_api_gateway_rest_api.enrollment-api.root_resource_id
  path_part   = "enrollment"
}

resource "aws_api_gateway_method" "enrollment-method" {
  rest_api_id   = aws_api_gateway_rest_api.enrollment-api.id
  resource_id   = aws_api_gateway_resource.enrollment-resource.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.api-auth.id
}

resource "aws_api_gateway_authorizer" "api-auth" {
  name                   = "enrollment-api-auth"
  rest_api_id            = aws_api_gateway_rest_api.enrollment-api.id
  authorizer_uri         = var.auth-fun-invoke-arn
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.enrollment-api.id
  resource_id             = aws_api_gateway_resource.enrollment-resource.id
  http_method             = aws_api_gateway_method.enrollment-method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.manipulator-fun-invoke-arn
}

resource "aws_api_gateway_deployment" "api-deployment" {
  rest_api_id = aws_api_gateway_rest_api.enrollment-api.id

   triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.enrollment-resource.id,
      aws_api_gateway_method.enrollment-method.id,
      aws_api_gateway_integration.integration.id,
    ]))
  }
  depends_on = [aws_api_gateway_method.enrollment-method, aws_api_gateway_integration.integration]
}

resource "aws_api_gateway_stage" "enrollment-stage" {
  deployment_id = aws_api_gateway_deployment.api-deployment.id
  rest_api_id   = aws_api_gateway_rest_api.enrollment-api.id
  stage_name    = "dev"
}
