terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.10.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "default_vpc" {
  default = true  
}

data "aws_subnet" "public_subnet" {
  vpc_id = data.aws_vpc.default_vpc.id
  availability_zone = "us-east-1a"
}

provider "archive" {}

data "archive_file" "zip" {
  type        = "zip"
  source_file = "greet_lambda.py"
  output_path = "greet_lambda.zip"  
}

resource "aws_cloudwatch_log_group" "function_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_iam_role" "iam_role_lambda" {
  name               = "iam_role_lambda"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action : "sts:AssumeRole",
        Effect : "Allow",
        Principal : {
          "Service" : "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "logging_policy" {
  name   = "logging-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action : [
          "logs:CreateLogStream",
          "logs:CreateLogDelivery",
          "logs:PutLogEvents"
        ],
        Effect : "Allow",
        Resource : "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "logging_policy_attachment" {
  role = aws_iam_role.iam_role_lambda.id
  policy_arn = aws_iam_policy.logging_policy.arn
}

resource "aws_lambda_function" "lambda" {
  function_name    = "greetings_lambda"
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256
  role             = aws_iam_role.iam_role_lambda.arn
  handler          = "greet_lambda.lambda_handler"
  runtime          = "python3.9"

  environment {
    variables = {
      greeting = "Hello"
    }
  }
} 

