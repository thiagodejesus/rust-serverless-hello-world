terraform {
  required_version = ">= 1.4.6"
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

locals {
  lambda_name = "serverless_rust_hello_world"
}

module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = local.lambda_name
  description   = "A simple lambda that says hello"
  runtime       = "provided.al2023"
  architectures = ["arm64"]
  handler       = "bootstrap"

  create_package         = false
  local_existing_package = "../../target/lambda/hello-world/bootstrap.zip"

  tags = {
    Name = local.lambda_name
  }
}
