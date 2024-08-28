locals {
  filename = split("/", var.file_path)[length(split("/", var.file_path)) - 1]
}

resource "aws_lambda_function" "this" {
  filename         = var.file_path
  function_name    = var.function_name
  role             = var.role_arn
  handler          = var.handler
  runtime          = var.runtime
  source_code_hash = filebase64sha256("${var.file_path}")
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.this.function_name}"
  retention_in_days = var.log_retention_in_days
}