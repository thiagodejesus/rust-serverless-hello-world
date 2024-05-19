locals {
  full_function_name = "${var.project_name}-${var.function_name}"
}

resource "aws_lambda_function" "this" {
  function_name = local.full_function_name
  role          = aws_iam_role.this.arn
  architectures = ["arm64"]
  filename      = var.deployment_file
  package_type  = "Zip"
  runtime       = "provided.al2023"
  handler       = "bootstrap.handler"
  timeout       = var.function_timeout
  
  logging_config {
    application_log_level = "INFO"
    log_format            = "JSON"
    system_log_level      = "INFO"
    log_group             = aws_cloudwatch_log_group.this.name
  }

  depends_on = [
    aws_cloudwatch_log_group.this,
    aws_iam_role.this,
  ]
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${local.full_function_name}"
  log_group_class   = "STANDARD"
  retention_in_days = 7
}

resource "aws_iam_role" "this" {
  name                  = local.full_function_name
  force_detach_policies = true
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "this" {
  name   = "function-permissions"
  role   = aws_iam_role.this.name
  policy = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "this" {
  statement {
    sid = "writeLogs"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    effect = "Allow"
    resources = [
      "${aws_cloudwatch_log_group.this.arn}:*"
    ]
  }
  statement {
    sid       = "createLogGroup"
    actions   = ["logs:CreateLogGroup"]
    effect    = "Allow"
    resources = ["arn:aws:logs:${data.aws_region.this.id}:${data.aws_caller_identity.this.id}:*"]
  }
}