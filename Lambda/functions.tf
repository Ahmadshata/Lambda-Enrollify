resource "local_file" "manipulator" {
  content  = <<EOF
import json
import boto3

dynamo = boto3.resource('dynamodb')
table = dynamo.Table('${var.dynamodb-table-name}')
lambda_client = boto3.client('lambda')

def lambda_handler(event, context):
    try:
        requestBody = json.loads(event["body"])
        response=table.put_item(Item=requestBody)
        msg = {'id': requestBody['id'], 'first_name': requestBody['first name'], 'last_name': requestBody['last name']}
        invoke_response = lambda_client.invoke(FunctionName="${var.sender-fun-name}", InvocationType='Event', Payload=json.dumps(msg))

        return {
            'statusCode': 200,
            'body': json.dumps(requestBody)
    }
    except:
        raise
  EOF
  filename = "${var.manipulator-fun-name}.py"
}

#Dynamodb manipulator function
data "archive_file" "manipulator" {
  type        = "zip"
  source_file = "${var.manipulator-fun-name}.py"
  output_path = "${var.manipulator-fun-name}.zip"
   depends_on = [
    local_file.manipulator
  ]
}

resource "aws_lambda_function" "manipulator" {
  filename      = "${var.manipulator-fun-name}.zip"
  function_name = var.manipulator-fun-name
  role          = aws_iam_role.manipulator-role.arn
  handler       = "${var.manipulator-fun-name}.lambda_handler"

  source_code_hash = data.archive_file.manipulator.output_base64sha256

  runtime = "python3.10"
}

resource "aws_cloudwatch_log_group" "manipulator-log" {
  name              = "/aws/lambda/${var.manipulator-fun-name}"
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
resource "local_file" "auth" {
  content  = <<EOF
import json
import boto3

client = boto3.client('secretsmanager')
secret_response = client.get_secret_value(SecretId='${var.secret-name}')
stored_secret = json.loads(secret_response['SecretString'])
token = stored_secret["JWT_TOKEN"]

def lambda_handler(event, context):
    auth = 'Deny'
    if event['authorizationToken'] == token:
        auth = 'Allow'
    else:
        auth = 'Deny'
    
    authResponse = { "principalId": "1", "policyDocument": { "Version": "2012-10-17", "Statement": [{"Action": "execute-api:Invoke", "Resource": ["arn:aws:execute-api:eu-west-2:253823388836:*/*/*"], "Effect": auth}] }}
    return authResponse
  EOF
  filename = "${var.auth-fun-name}.py"
}

data "archive_file" "auth" {
  type        = "zip"
  source_file = "${var.auth-fun-name}.py"
  output_path = "${var.auth-fun-name}.zip"
   depends_on = [
    local_file.auth
  ]
}

resource "aws_lambda_function" "auth" {
  filename      = "${var.auth-fun-name}.zip"
  function_name = var.auth-fun-name
  role          = aws_iam_role.sender-auth-role.arn
  handler       = "${var.auth-fun-name}.lambda_handler"
#Used to trigger updates if the file SHA changed. Must be set to a base64-encoded SHA256 hash of the package file.
  source_code_hash = data.archive_file.auth.output_base64sha256
  runtime = "python3.10"
}

resource "aws_cloudwatch_log_group" "auth-log" {
  name              = "/aws/lambda/${var.auth-fun-name}"
  retention_in_days = 14
}

resource "aws_lambda_permission" "sender_permission" {
  statement_id  = "AllowMyAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.auth-fun-name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${var.api-execution-arn}/*/*"
}

#Mail sending function
resource "local_file" "sender" {
  content  = <<EOF
import json
import os
from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Mail
import boto3

client = boto3.client('secretsmanager')
secret_response = client.get_secret_value(SecretId='${var.secret-name}')
stored_secret = json.loads(secret_response['SecretString'])
api_key = stored_secret["API_KEY"]

def lambda_handler(event, context):
    message = Mail(
        from_email='${var.sender-email}',
        to_emails='${var.receiver-email}',
        subject='New user just got added',
        html_content=f"""
        <strong>New user added with data:</strong><br><br>
        <table width="1000" style="border:1px solid #333">
            <tr style="border:1px solid #333">
                <th width="200" align="center" style="border:1px solid #333">ID</th>
                <th width="200" align="center" style="border:1px solid #333">First name</th>
                <th width="200" align="center" style="border:1px solid #333">Last name</th>
            </tr>
            <tr style="border:1px solid #333">
                <td align="center" style="border:1px solid #333">{event['id']}</td>
                <td align="center" style="border:1px solid #333">{event['first_name']}</td>
                <td align="center" style="border:1px solid #333">{event['last_name']}</td>
            </tr>
        </table>"""
        )

    try:
        sg = SendGridAPIClient(api_key)
        response = sg.send(message)
        print(response.status_code)
        print(response.body)
        print(response.headers)
    except Exception as e:
        print(e)
  EOF
  filename = "${var.sender-fun-name}.py"
}
data "archive_file" "sender" {
  type        = "zip"
  source_file = "${var.sender-fun-name}.py"
  output_path = "${var.sender-fun-name}.zip"
   depends_on = [
    local_file.sender
  ]
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
  filename      = "${var.sender-fun-name}.zip"
  function_name =  var.sender-fun-name
  role          = aws_iam_role.sender-auth-role.arn
  handler       = "${var.sender-fun-name}.lambda_handler"

  source_code_hash = data.archive_file.sender.output_base64sha256

  runtime = "python3.10"
  layers = [aws_lambda_layer_version.sendgrid-lambda-layer.arn]
}

resource "aws_cloudwatch_log_group" "sender-log" {
  name              = "/aws/lambda/${var.sender-fun-name}"
  retention_in_days = 14
}

