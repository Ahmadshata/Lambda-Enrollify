module "dynamodb"{
    source = "./Dynamodb"
}

module "lambda" {
    source = "./Lambda"
    manipulator-fun-name = "manipulator"
    auth-fun-name = "authenticator"
    sender-fun-name = "Mail-sender"
    secrets-manager = module.secrets.secrets-arn
    region = "eu-west-2"
    db-arn = module.dynamodb.db-arn
    api-execution-arn = module.enrollment-api.api-execution-arn
}

module "secrets" {
    source = "./Secrets-Manager"
    secrets = var.secrets
}

module "acm" {
    source = "./ACM"
}

module "enrollment-api" {
    source = "./API_GATEWAY"
    auth-fun-invoke-arn = module.lambda.auth-fun-invoke-arn
    manipulator-fun-invoke-arn = module.lambda.manipulator-fun-invoke-arn
}
