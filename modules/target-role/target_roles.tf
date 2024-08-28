data "aws_iam_policy_document" "pettamer_target_assume_role_policy" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.controller_account_id]
    }
  }
}

resource "aws_iam_role" "pettamer_target_role" {
  name = "pettamer_target_role"

  assume_role_policy = data.aws_iam_policy_document.pettamer_target_assume_role_policy.json
}

data "aws_iam_policy_document" "pettamer_target_policy_document" {
  statement {
    actions = [
      "ssm:SendCommand",
      "ssm:GetParameter",
      "ec2:StopInstances",
      "ec2:StartInstances"
    ]

    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Servicegroup"
      values   = ["*"]
    }

    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = ["ec2:DescribeInstances"]
    effect  = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "pettamer_target_policy" {
  name   = "pettamer_target_policy"
  role   = aws_iam_role.pettamer_target_role.id
  policy = data.aws_iam_policy_document.pettamer_target_policy_document.json
}
