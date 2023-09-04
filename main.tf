module "dynamodb"{
    source                                  = "./Dynamodb"
    table-name                              = "enrollment" 
    billing-mode                            = "PAY_PER_REQUEST"
    partition-key                           = "id"
    key-data-type                           = "S"
}

module "lambda" {
    source                                  = "./Lambda"
    manipulator-fun-name                    = "manipulator"
    auth-fun-name                           = "authenticator"
    sender-fun-name                         = "Mail-sender"
    function-runtime                        = "python3.10"
    CW-logs-retention-days                  = 14
    region                                  = "eu-west-2"
    secret-name                             = "lambda-secrets"
    sender-email                            = "4ata12@gmail.com"
    receiver-email                          = "ahmadesmailshata@gmail.com"
    secret-arn                              = module.secrets.secrets-arn
    db-arn                                  = module.dynamodb.db-arn
    api-execution-arn                       = module.enrollment-api.api-execution-arn
    dynamodb-table-name                     = module.dynamodb.dynamodb-table-name
}

module "secrets" {
    source                                  = "./Secrets-Manager"
    secret-name                             = "lambda-secrets"
    secrets                                 = var.secrets
}

module "acm" {
    source                                  = "./ACM"
    domain-name                             = "api.ashata.online"
    validation-method                       = "DNS"
    existing-public-route53-zone-name       = "ashata.online"
    allow-overwrite                         = false
}

module "enrollment-api" {
    source                                  = "./API_GATEWAY"
    api-name                                = "enrollment"
    api-type                                = ["REGIONAL"]
    resource-name                           = "enrollment"
    authorizer-name                         = "enrollment-api-auth"
    stage-name                              = "dev"
    custom-domain-name                      = "api.ashata.online"
    evaluate-target-health                  = true
    auth-fun-invoke-arn                     = module.lambda.auth-fun-invoke-arn
    manipulator-fun-invoke-arn              = module.lambda.manipulator-fun-invoke-arn
    certificate-arn                         = module.acm.certificate-arn
    zone-id                                 = module.acm.zone-id
}
