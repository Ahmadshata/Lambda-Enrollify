resource "aws_api_gateway_rest_api" "enrollment-api" {
  name                              = var.api-name
  endpoint_configuration {
    types                           = var.api-type
  }
}

resource "aws_api_gateway_resource" "enrollment-resource" {
  rest_api_id                       = aws_api_gateway_rest_api.enrollment-api.id
  parent_id                         = aws_api_gateway_rest_api.enrollment-api.root_resource_id
  path_part                         = var.resource-name
}

resource "aws_api_gateway_method" "enrollment-method" {
  rest_api_id                       = aws_api_gateway_rest_api.enrollment-api.id
  resource_id                       = aws_api_gateway_resource.enrollment-resource.id
  http_method                       = "POST"
  authorization                     = "CUSTOM" 
  authorizer_id                     = aws_api_gateway_authorizer.api-auth.id
  api_key_required                  = true
}

resource "aws_api_gateway_authorizer" "api-auth" {
  name                              = var.authorizer-name
  rest_api_id                       = aws_api_gateway_rest_api.enrollment-api.id
  authorizer_uri                    = var.auth-fun-invoke-arn
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id                       = aws_api_gateway_rest_api.enrollment-api.id
  resource_id                       = aws_api_gateway_resource.enrollment-resource.id
  http_method                       = aws_api_gateway_method.enrollment-method.http_method
  integration_http_method           = "POST"
  type                              = "AWS_PROXY"
  uri                               = var.manipulator-fun-invoke-arn
}

resource "aws_api_gateway_deployment" "api-deployment" {
  rest_api_id                       = aws_api_gateway_rest_api.enrollment-api.id

   triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.enrollment-resource.id,
      aws_api_gateway_method.enrollment-method.id,
      aws_api_gateway_integration.integration.id,
    ]))
  }
  depends_on                        = [aws_api_gateway_method.enrollment-method, aws_api_gateway_integration.integration]
}

resource "aws_api_gateway_stage" "enrollment-stage" {
  deployment_id                     = aws_api_gateway_deployment.api-deployment.id
  rest_api_id                       = aws_api_gateway_rest_api.enrollment-api.id
  stage_name                        = var.stage-name
}

resource "aws_api_gateway_usage_plan" "enrollment-usageplan" {
  name = "enrollment-usage-plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.enrollment-api.id
    stage  = aws_api_gateway_stage.enrollment-stage.stage_name
  }
  
   throttle_settings {
    burst_limit = 5
    rate_limit  = 10
  }
}

resource "aws_api_gateway_api_key" "enrollment-key" {
  name = "enrollment-key"
}

resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = aws_api_gateway_api_key.enrollment-key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.enrollment-usageplan.id
}

resource "aws_api_gateway_domain_name" "custom-domain" {
  domain_name                       = var.custom-domain-name
  regional_certificate_arn          = var.certificate-arn

  endpoint_configuration {
    types                           = ["REGIONAL"]
  }
}

resource "aws_route53_record" "custom-domain" {
  name                              = aws_api_gateway_domain_name.custom-domain.domain_name
  type                              = "A"
  zone_id                           = var.zone-id

  alias {
    evaluate_target_health          = var.evaluate-target-health
    name                            = aws_api_gateway_domain_name.custom-domain.regional_domain_name
    zone_id                         = aws_api_gateway_domain_name.custom-domain.regional_zone_id
  }
}

resource "aws_api_gateway_base_path_mapping" "custom-domain" {
  api_id                            = aws_api_gateway_rest_api.enrollment-api.id
  stage_name                        = aws_api_gateway_stage.enrollment-stage.stage_name
  domain_name                       = aws_api_gateway_domain_name.custom-domain.domain_name
}