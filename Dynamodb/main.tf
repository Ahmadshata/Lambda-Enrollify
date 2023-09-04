resource "aws_dynamodb_table" "enrollment" {
  name                        = "enrollment"
  billing_mode                = "PAY_PER_REQUEST"
  hash_key                    = "id"

  attribute {
    name                      = "id"
    type                      = "S"
  }
}
