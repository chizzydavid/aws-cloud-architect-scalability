# TODO: Define the output variable for the lambda function.

output "terraform_aws_role_name" {
  value = aws_iam_role.iam_role_lambda.name
}

output "terraform_aws_role_arn" {
  value = aws_iam_role.iam_role_lambda.arn
}
