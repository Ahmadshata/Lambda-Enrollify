
#Dynamodb manipulator function
data "archive_file" "manipulator" {
  type        = "zip"
  source_file = "manipulator.py"
  output_path = "manipulator.zip"
}

resource "aws_lambda_function" "manipulator" {
  filename      = "manipulator.zip"
  function_name = var.manipulator-fun-name
  role          = aws_iam_role.manipulator-role.arn
  handler       = "manipulator.lambda_handler"

  source_code_hash = data.archive_file.manipulator.output_base64sha256

  runtime = "python3.10"
}

resource "aws_cloudwatch_log_group" "manipulator-log" {
  name              = "/aws/lambda/manipulator"
  retention_in_days = 14
}

resource "aws_lambda_permission" "manipulator_permission" {
  statement_id  = "AllowMyAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.manipulator-fun-name
  principal     = "apigateway.amazonaws.com"

  # The /* part allows invocation from any stage, method and resource path
  # within API Gateway.
  source_arn = "${var.api-execution-arn}/*/*"
}

#Api-gateway auth function
data "archive_file" "auth" {
  type        = "zip"
  source_file = "auth.py"
  output_path = "auth.zip"
}

resource "aws_lambda_function" "auth" {
  filename      = "auth.zip"
  function_name = var.auth-fun-name
  role          = aws_iam_role.sender-auth-role.arn
  handler       = "auth.lambda_handler"

  source_code_hash = data.archive_file.auth.output_base64sha256

  runtime = "python3.10"
}

resource "aws_cloudwatch_log_group" "auth-log" {
  name              = "/aws/lambda/authenticator"
  retention_in_days = 14
}

resource "aws_lambda_permission" "sender_permission" {
  statement_id  = "AllowMyAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.auth-fun-name
  principal     = "apigateway.amazonaws.com"

  # The /* part allows invocation from any stage, method and resource path
  # within API Gateway.
  source_arn = "${var.api-execution-arn}/*/*"
}

#Mail sending function
data "archive_file" "sender" {
  type        = "zip"
  source_file = "sender.py"
  output_path = "sender.zip"
}

#Creating a s3 bucket to conatin the layer zip file.
resource "aws_s3_bucket" "auth-layer-bucket" {
  bucket = "shata-lambda-auth-layer"
}

#Putting the layer zip file in the bucket.
resource "aws_s3_object" "lambda-layer-zip" {
  bucket     = aws_s3_bucket.auth-layer-bucket.id
  key        = "lambda_layers/sendgrid-layer"
  source     = "sendgrid.zip"
}

#Creating a layer out of the zip file.
resource "aws_lambda_layer_version" "sendgrid-lambda-layer" {
  s3_bucket           = aws_s3_bucket.auth-layer-bucket.id
  s3_key              = aws_s3_object.lambda-layer-zip.key
  layer_name          = "sendgrid"
  compatible_runtimes = ["python3.10"]
}

resource "aws_lambda_function" "sender" {
  filename      = "sender.zip"
  function_name =  var.sender-fun-name
  role          = aws_iam_role.sender-auth-role.arn
  handler       = "sender.lambda_handler"

  source_code_hash = data.archive_file.sender.output_base64sha256

  runtime = "python3.10"
  layers = [aws_lambda_layer_version.sendgrid-lambda-layer.arn]
}

resource "aws_cloudwatch_log_group" "sender-log" {
  name              = "/aws/lambda/Mail-sender"
  retention_in_days = 14
}

