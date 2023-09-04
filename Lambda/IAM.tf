data "aws_caller_identity" "current" {}

resource "aws_iam_role" "sender-auth-role" {
  name                    = "${var.sender-fun-name}-${var.auth-fun-name}-role"
  assume_role_policy      = jsonencode({
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
  name                    = "${var.manipulator-fun-name}-role"
  assume_role_policy      = jsonencode({
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
  name                    = "${var.sender-fun-name}-${var.auth-fun-name}-policy"
  policy                  = jsonencode(
        {
        "Version": "2012-10-17",
        "Statement": [
                {
                        "Sid": "VisualEditor0",
                        "Effect": "Allow",
                        "Action": "secretsmanager:GetSecretValue",
                        "Resource": "${var.secret-arn}"
                },
        {
                        "Effect": "Allow",
                        "Action": [
                                "logs:CreateLogStream",
                                "logs:PutLogEvents",
                                "logs:CreateLogGroup"
                        ],
                        "Resource": ["arn:aws:logs:*:*:*"]
                },
        ]
})
}

resource "aws_iam_policy" "lambda-manipulator" {
  name                      = "${var.manipulator-fun-name}-policy"
  policy                    = jsonencode(
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
                                "logs:PutLogEvents",
                                "logs:CreateLogGroup"
                        ],
                        "Resource": ["arn:aws:logs:*:*:*"]
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
  policy_arn                  = aws_iam_policy.lambda-sender-authorizer.arn
  role                        = aws_iam_role.sender-auth-role.name
}

resource "aws_iam_role_policy_attachment" "manipulator-attach" {
  policy_arn                  = aws_iam_policy.lambda-manipulator.arn
  role                        = aws_iam_role.manipulator-role.name
}

