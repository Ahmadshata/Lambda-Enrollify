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
}

module "secrets" {
  source = "./Secrets-Manager"
  secrets = var.secrets
}
