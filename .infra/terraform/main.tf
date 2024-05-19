terraform {
  required_version = ">= 1.8.3"
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

locals {
  lambda_name = "serverless_rust_hello_world"
}

module "serverless_rust_hello_world" {
  source = "./modules/lambda"
  function_name = local.lambda_name
  function_timeout = 1
  deployment_file = "../../target/lambda/hello-world/bootstrap.zip"
  project_name = var.project_name
}