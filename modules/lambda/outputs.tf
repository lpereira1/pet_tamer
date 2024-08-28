output "lambda_function_arn" {
  description = "The ARN of the deployed Lambda function."
  value       = aws_lambda_function.this.arn
}

output "lambda_function_name" {
  description = "The name of the deployed Lambda function."
  value       = aws_lambda_function.this.function_name
}

output "lambda_function_role" {
  description = "The ARN of the IAM role used by the Lambda function."
  value       = aws_lambda_function.this.role
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group for the Lambda function."
  value       = aws_cloudwatch_log_group.lambda_log_group.name
}

output "cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch log group for the Lambda function."
  value       = aws_cloudwatch_log_group.lambda_log_group.arn
}

output "lambda_invoke_arn"{
  value = aws_lambda_function.this.invoke_arn
}