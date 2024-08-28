variable "file_path" {
  description = "The path to the Lambda deployment package file."
  type        = string
}

variable "function_name" {
  description = "The name of the Lambda function."
  type        = string
}

variable "role_arn" {
  description = "The ARN of the IAM role that the Lambda function will use."
  type        = string
}

variable "handler" {
  description = "The function handler in the Lambda function."
  type        = string
}

variable "runtime" {
  description = "The runtime environment for the Lambda function."
  type        = string
  default     = "python3.9"  # Defaulting to Python 3.9, can be changed if needed
}

variable "log_retention_in_days" {
  description = "The number of days worth of cloudwatch logs to keep."
  type        = number
  default     = 3
}

