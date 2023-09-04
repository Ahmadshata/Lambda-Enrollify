output "db-arn" {
  value = aws_dynamodb_table.enrollment.arn
}

output "dynamodb-table-name" {
  value = aws_dynamodb_table.enrollment.id
}