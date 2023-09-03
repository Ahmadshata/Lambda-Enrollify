data "aws_caller_identity" "current" {}

resource "aws_iam_role" "sender-auth-role" {
  name = "sender-auth-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role" "manipulator-role" {
  name = "manipulator-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "lambda-sender-authorizer" {
  name        = "lambda-sender-authorizer-policy"
  policy = jsonencode(
        {
        "Version": "2012-10-17",
        "Statement": [
                {
                        "Sid": "VisualEditor0",
                        "Effect": "Allow",
                        "Action": "secretsmanager:GetSecretValue",
                        "Resource": "${var.secrets-manager}"
                },
        {
                        "Effect": "Allow",
                        "Action": [
                                "logs:CreateLogStream",
                                "logs:PutLogEvents"
                        ],
                        "Resource": ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"]
                },
                {
                        "Effect": "Allow",
                        "Action": "logs:CreateLogGroup",
                        "Resource": "*"
                }
        ]
})
}

resource "aws_iam_policy" "lambda-manipulator" {
  name        = "lambda-manipulator-policy"
  policy = jsonencode(
{
        "Version": "2012-10-17",
        "Statement": [{
                        "Effect": "Allow",
                        "Action": [
                                "dynamodb:BatchGetItem",
                                "dynamodb:GetItem",
                                "dynamodb:Query",
                                "dynamodb:Scan",
                                "dynamodb:BatchWriteItem",
                                "dynamodb:PutItem",
                                "dynamodb:UpdateItem"
                        ],
                        "Resource": "${var.db-arn}"
                },
                {
                        "Effect": "Allow",
                        "Action": [
                                "logs:CreateLogStream",
                                "logs:PutLogEvents"
                        ],
                        "Resource": "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"
                },
                {
                        "Effect": "Allow",
                        "Action": "logs:CreateLogGroup",
                        "Resource": "*"
                },
                {
                        "Effect": "Allow",
                        "Action": "lambda:InvokeFunction",
                        "Resource": "${aws_lambda_function.sender.arn}"
                }
        
        ]
})
}

resource "aws_iam_role_policy_attachment" "sender-authorizer-attach" {
  policy_arn = aws_iam_policy.lambda-sender-authorizer.arn
  role = aws_iam_role.sender-auth-role.name
}

resource "aws_iam_role_policy_attachment" "manipulator-attach" {
  policy_arn = aws_iam_policy.lambda-manipulator.arn
  role = aws_iam_role.manipulator-role.name
}
