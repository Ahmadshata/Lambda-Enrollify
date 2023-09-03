output "secrets-arn" {
  value = aws_secretsmanager_secret.my-secret.arn
}