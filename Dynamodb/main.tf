resource "aws_dynamodb_table" "enrollment" {
  name                        = var.table-name
  billing_mode                = var.billing-mode
  hash_key                    = var.partition-key

  attribute {
    name                      = var.partition-key
    type                      = var.key-data-type
  }
}
