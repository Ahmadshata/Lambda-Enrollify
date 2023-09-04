module "dynamodb"{
    source                          = "./Dynamodb"
}

module "lambda" {
    source                          = "./Lambda"
    manipulator-fun-name            = "manipulator"
    auth-fun-name                   = "authenticator"
    sender-fun-name                 = "Mail-sender"
    secrets-manager                 = module.secrets.secrets-arn
    region                          = "eu-west-2"
    db-arn                          = module.dynamodb.db-arn
    api-execution-arn               = module.enrollment-api.api-execution-arn
    dynamodb-table-name             = module.dynamodb.dynamodb-table-name
    secret-name                     = "lambda-secrets"
    sender-email                    = "4ata12@gmail.com"
    receiver-email                  = "ahmadesmailshata@gmail.com"
}

module "secrets" {
    source                          = "./Secrets-Manager"
    secrets                         = var.secrets
    secret-name                     = "lambda-secrets"
}

module "acm" {
    source                          = "./ACM"
}

module "enrollment-api" {
    source                          = "./API_GATEWAY"
    auth-fun-invoke-arn             = module.lambda.auth-fun-invoke-arn
    manipulator-fun-invoke-arn      = module.lambda.manipulator-fun-invoke-arn
}
