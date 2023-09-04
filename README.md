# Lambda-Enrollify

![Lambda-Enrollify](https://github.com/Ahmadshata/Lambda-Enrollify/assets/124501795/e2cc6c25-31f1-4a3b-bcf5-f5ba4de051db)

This project utilizes Terraform to deploy an API Gateway with a CUSTOM authorizer. The authorizer, implemented as a Lambda function, is also deployed using Terraform. Here's how the process works:

1. **API Gateway and Authorizer**: The Terraform script deploys an API Gateway with a custom authorizer Lambda function named `authorizer`. The `authorizer` checks for a JWT token in the request header.

2. **Request Processing**: If a valid JWT token and an API-Key is passed in the request headers, the API Gateway triggers another Lambda function called `manipulator`.

3. **Data Manipulation**: The `manipulator` Lambda function extracts information from the request body and inserts the data into a DynamoDB table. The DynamoDB table creation is also managed by Terraform.

4. **Email Notification**: Once the data is inserted into DynamoDB, the `manipulator` function triggers another Lambda function called `Mail-sender`. This function uses SendGrid, a cloud-based SMTP provider, to send an email to a specified email address. The email contains the data that was inserted into DynamoDB.

This project demonstrates how to set up a secure API Gateway with custom authentication, data processing using Lambda functions, and email notifications. It leverages the power of Terraform for infrastructure management and integrates with SendGrid for email communication.

## Prerequisites

- [Terraform](https://www.terraform.io/) installed and configured
- [AWS Account](https://aws.amazon.com/) with necessary permissions
- [SendGrid Account](https://sendgrid.com/) for email sending capabilities

## Usage

1. Clone this repository.
  ```bash
  git clone https://github.com/Ahmadshata/Lambda-Enrollify.git
  ```
2. Create a new file called /terraform.tfvars
  ```bash
  touch terraform.tfvars
  ```
3. Configure your AWS credentials and SendGrid API key in the /terraform.tfvars file.
 ```bash
  secrets = {
    JWT_TOKEN = "REPLACE_WITH_YOUR_JWT_TOKEN",
    API_KEY = "REPLACE_WITH_YOUR_SENDGRID_API_KEY"
  }
  ```
4. Carefully review the configuration parameters within the `main.tf` file. This file contains settings for the deployment of AWS resources, including the API Gateway, Lambda functions, and DynamoDB table.
5. Modify the values of the configuration arguments to align with your use case.
6. Modify the backend S3-bucket and DynamoDB names and arguments in the `backend.tf
7. Run `terraform init` to initialize the project.
8. Run `terraform apply` to deploy the infrastructure.
9. Test the API Gateway by sending requests with a valid JWT token and API-key in the header (The header key for the JWT token will be "Authorization" and for the API-key it will be "x-api-key".
10. Monitor the DynamoDB table for data insertion.
11. Check your email for notifications sent by the `Mail-sender` Lambda function.


## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.15.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm"></a> [acm](#module\_acm) | ./ACM | V1.0 |
| <a name="module_dynamodb"></a> [dynamodb](#module\_dynamodb) | ./Dynamodb | V1.0 |
| <a name="module_enrollment-api"></a> [enrollment-api](#module\_enrollment-api) | ./API_GATEWAY | V1.0 |
| <a name="module_lambda"></a> [lambda](#module\_lambda) | ./Lambda | V1.0 |
| <a name="module_secrets"></a> [secrets](#module\_secrets) | ./Secrets-Manager | V1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.terraform-lockstate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_s3_bucket.terraform-state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_versioning.enabled](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_secrets"></a> [secrets](#input\_secrets) | The JWT token & the SendGrid API-key | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api-key-value"></a> [api-key-value](#output\_api-key-value) | The API-Gateway API-key passed in the request header |
| <a name="output_custom-domain-invoke-url"></a> [custom-domain-invoke-url](#output\_custom-domain-invoke-url) | The API invokation-URL |

# ACM module

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.15.0 |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.domain-cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.validating](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_route53_record.validation-record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.hosted-zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow-overwrite"></a> [allow-overwrite](#input\_allow-overwrite) | n/a | `bool` | `false` | no |
| <a name="input_domain-name"></a> [domain-name](#input\_domain-name) | n/a | `string` | n/a | yes |
| <a name="input_existing-public-route53-zone-name"></a> [existing-public-route53-zone-name](#input\_existing-public-route53-zone-name) | n/a | `string` | n/a | yes |
| <a name="input_validation-method"></a> [validation-method](#input\_validation-method) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_certificate-arn"></a> [certificate-arn](#output\_certificate-arn) | n/a |
| <a name="output_zone-id"></a> [zone-id](#output\_zone-id) | n/a |

# API-GATEWAY module


## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.15.0 |

## Resources

| Name | Type |
|------|------|
| [aws_api_gateway_api_key.enrollment-key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_api_key) | resource |
| [aws_api_gateway_authorizer.api-auth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_authorizer) | resource |
| [aws_api_gateway_base_path_mapping.custom-domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_base_path_mapping) | resource |
| [aws_api_gateway_deployment.api-deployment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment) | resource |
| [aws_api_gateway_domain_name.custom-domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_domain_name) | resource |
| [aws_api_gateway_integration.integration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_method.enrollment-method](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_resource.enrollment-resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_rest_api.enrollment-api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api) | resource |
| [aws_api_gateway_stage.enrollment-stage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_stage) | resource |
| [aws_api_gateway_usage_plan.enrollment-usageplan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_usage_plan) | resource |
| [aws_api_gateway_usage_plan_key.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_usage_plan_key) | resource |
| [aws_route53_record.custom-domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api-name"></a> [api-name](#input\_api-name) | n/a | `string` | n/a | yes |
| <a name="input_api-type"></a> [api-type](#input\_api-type) | n/a | `list(string)` | n/a | yes |
| <a name="input_auth-fun-invoke-arn"></a> [auth-fun-invoke-arn](#input\_auth-fun-invoke-arn) | n/a | `string` | n/a | yes |
| <a name="input_authorizer-name"></a> [authorizer-name](#input\_authorizer-name) | n/a | `string` | n/a | yes |
| <a name="input_certificate-arn"></a> [certificate-arn](#input\_certificate-arn) | n/a | `string` | n/a | yes |
| <a name="input_custom-domain-name"></a> [custom-domain-name](#input\_custom-domain-name) | n/a | `string` | n/a | yes |
| <a name="input_evaluate-target-health"></a> [evaluate-target-health](#input\_evaluate-target-health) | n/a | `bool` | n/a | yes |
| <a name="input_manipulator-fun-invoke-arn"></a> [manipulator-fun-invoke-arn](#input\_manipulator-fun-invoke-arn) | n/a | `string` | n/a | yes |
| <a name="input_resource-name"></a> [resource-name](#input\_resource-name) | n/a | `string` | n/a | yes |
| <a name="input_stage-name"></a> [stage-name](#input\_stage-name) | n/a | `string` | n/a | yes |
| <a name="input_zone-id"></a> [zone-id](#input\_zone-id) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api-execution-arn"></a> [api-execution-arn](#output\_api-execution-arn) | n/a |
| <a name="output_api-key-value"></a> [api-key-value](#output\_api-key-value) | n/a |
| <a name="output_custom-domain-name"></a> [custom-domain-name](#output\_custom-domain-name) | n/a |
| <a name="output_invoke-url"></a> [invoke-url](#output\_invoke-url) | n/a |
| <a name="output_resource-name"></a> [resource-name](#output\_resource-name) | n/a |

# Dynamodb module

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.15.0 |

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.enrollment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_billing-mode"></a> [billing-mode](#input\_billing-mode) | n/a | `string` | n/a | yes |
| <a name="input_key-data-type"></a> [key-data-type](#input\_key-data-type) | n/a | `string` | n/a | yes |
| <a name="input_partition-key"></a> [partition-key](#input\_partition-key) | n/a | `string` | n/a | yes |
| <a name="input_table-name"></a> [table-name](#input\_table-name) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db-arn"></a> [db-arn](#output\_db-arn) | n/a |
| <a name="output_dynamodb-table-name"></a> [dynamodb-table-name](#output\_dynamodb-table-name) | n/a |

# Lambda module

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.15.0 |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.auth-log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.manipulator-log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.sender-log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.lambda-manipulator](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.lambda-sender-authorizer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.manipulator-role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.sender-auth-role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.manipulator-attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.sender-authorizer-attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.auth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function.manipulator](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function.sender](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_layer_version.sendgrid-lambda-layer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_layer_version) | resource |
| [aws_lambda_permission.manipulator_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.sender_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_s3_bucket.auth-layer-bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_object.lambda-layer-zip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [local_file.auth](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.manipulator](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.sender](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [archive_file.auth](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [archive_file.manipulator](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [archive_file.sender](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_CW-logs-retention-days"></a> [CW-logs-retention-days](#input\_CW-logs-retention-days) | n/a | `string` | n/a | yes |
| <a name="input_api-execution-arn"></a> [api-execution-arn](#input\_api-execution-arn) | n/a | `string` | n/a | yes |
| <a name="input_auth-fun-name"></a> [auth-fun-name](#input\_auth-fun-name) | n/a | `string` | n/a | yes |
| <a name="input_db-arn"></a> [db-arn](#input\_db-arn) | n/a | `string` | n/a | yes |
| <a name="input_dynamodb-table-name"></a> [dynamodb-table-name](#input\_dynamodb-table-name) | n/a | `string` | n/a | yes |
| <a name="input_function-runtime"></a> [function-runtime](#input\_function-runtime) | n/a | `string` | n/a | yes |
| <a name="input_manipulator-fun-name"></a> [manipulator-fun-name](#input\_manipulator-fun-name) | n/a | `string` | n/a | yes |
| <a name="input_receiver-email"></a> [receiver-email](#input\_receiver-email) | n/a | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | n/a | yes |
| <a name="input_secret-arn"></a> [secret-arn](#input\_secret-arn) | n/a | `string` | n/a | yes |
| <a name="input_secret-name"></a> [secret-name](#input\_secret-name) | n/a | `string` | n/a | yes |
| <a name="input_sender-email"></a> [sender-email](#input\_sender-email) | n/a | `string` | n/a | yes |
| <a name="input_sender-fun-name"></a> [sender-fun-name](#input\_sender-fun-name) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_auth-fun-invoke-arn"></a> [auth-fun-invoke-arn](#output\_auth-fun-invoke-arn) | n/a |
| <a name="output_manipulator-fun-invoke-arn"></a> [manipulator-fun-invoke-arn](#output\_manipulator-fun-invoke-arn) | n/a |

# Secrets-Manager module

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.15.0 |

## Resources

| Name | Type |
|------|------|
| [aws_secretsmanager_secret.my-secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.my-secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_secret-name"></a> [secret-name](#input\_secret-name) | n/a | `string` | n/a | yes |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | n/a | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_secrets-arn"></a> [secrets-arn](#output\_secrets-arn) | n/a |
                                                                                                                                                                                                                                                                                                                                                                                                                                     
## License

This project is licensed under the [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0).

