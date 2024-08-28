resource "aws_iam_role" "lambda_role" {
  name = "lambda_pettamer_controller_role"

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    effect = "Allow"
  }
}

data "aws_iam_policy_document" "lambda_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    resources = ["arn:aws:iam::*:role/pettamer_target_role"]

    effect = "Allow"
  }

  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParameterHistory",
      "ssm:DescribeParameters"
    ]

    resources = [
      "arn:aws:ssm:${var.region}:${var.controller_account_id}:parameter/pettamer/*"
    ]

    effect = "Allow"
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda_pettamer_controller_policy"
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_policy_document.json
}
