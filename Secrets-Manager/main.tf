resource "aws_secretsmanager_secret" "my-secret" {
  name                        = var.secret-name
}

resource "aws_secretsmanager_secret_version" "my-secret" {
  secret_id                   = aws_secretsmanager_secret.my-secret.id
  secret_string               = jsonencode(var.secrets)
}