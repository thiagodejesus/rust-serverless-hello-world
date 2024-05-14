# How to Create an AWS Rust Lambda Behind an API Gateway and Deploy it Using Docker and Terraform

Why Rust, Serverless, and Terraform?
Rust: I like Rust for its emphasis on safety so i am testing some approaches to use it on a realty closer of mine.

Serverless: Deploying projects as serverless functions simplifies experimentation and initial project launches.

Terraform: Leveraging Infrastructure as Code (IaC) is preferable over manual setups due to versioning and reproducibility benefits. Terraform, being widely adopted, looks like a good way to start with IaC.

## Requirements

- Cargo Lambda: AWS provides cargo lambda, a CLI tool to streamline the development of serverless Rust applications.

1. Create the lambda

To kickstart the project, we'll use cargo lambda to scaffold a new Rust project. By adding the --http flag, we configure it to handle HTTP requests from an API Gateway.

```sh
cargo lambda new --http hello-world
```

This command generates a new Rust project with a basic template, we gonna made quick changes on it so the main.rs file will be like this:

```rs
use lambda_http::{run, service_fn, tracing, Body, Error, Request, RequestExt, Response};

async fn function_handler(event: Request) -> Result<Response<Body>, Error> {
    let who = event
        .query_string_parameters_ref()
        .and_then(|params| params.first("name"))
        .unwrap_or("world");

    let message = format!("Hello {who}!");

    let resp = Response::builder()
        .status(200)
        .header("content-type", "text/html")
        .body(message.into())
        .map_err(Box::new)?;
    Ok(resp)
}

#[tokio::main]
async fn main() -> Result<(), Error> {
    tracing::init_default_subscriber();

    run(service_fn(function_handler)).await
}

```

Its a simple code that extracts the param `name` for the query, or default its value to world. Then we create a message and returns it as an Response.

Now, our function is ready, we can run it with `cargo lambda watch` then make a test request with `curl http://localhost:9000/\?name\="Wilson"` to receive a `Hello Wilson`.

To prepare for deployment, we'll build the Lambda function to generate the bootstrap.zip file

`cargo lambda build --release --arm64 --output-format zip`

2. Setting Up Terraform

To manage our AWS infrastructure, we'll use Terraform. Let's begin by organizing our Terraform files within a dedicated folder .infra/terraform. Inside this folder, create a file named main.tf and add the following code:

File: .infra/terraform/main.tf
```tf
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
  runtime = "provided.al2023"
  architectures = ["arm64"]
  handler = "bootstrap"

  create_package         = false
  local_existing_package = "../../target/lambda/hello-world/bootstrap.zip"

  tags = {
    Name = local.lambda_name
  }
}
```

Next, define the variables required for our Terraform configuration in a file named variables.tf:

File: .infra/terraform/variables.tf
```tf
variable "aws_region" {
  default = "us-east-1"
  type    = string
}

variable "env" {
  default     = "dev"
  type        = string
  description = "The environment to deploy to"

}

variable "aws_profile" {
  type        = string
  description = "The aws profile to use when running terraform"
}

```

Now, let's build our Lambda function. Navigate to the Terraform directory:
`cd .infra/terraform`

Initialize Terraform:
`terraform init`

To preview the changes before applying them, run:
`terraform plan` to see what is going to be created


Now, let's test our Lambda function on AWS. Below is the event payload format required for testing, tailored for AWS API Gateway:
```
{
  "queryStringParameters": {
    "name": "Ago"
  },
  "requestContext": {
    "http": {
      "method": "GET",
      "path": "/",
      "protocol": "HTTP/1.1",
      "sourceIp": "192.0.2.1",
      "userAgent": "agent"
    }
  }
}
```

Thats it, we already have a lambda working, on the next step we will setup the api gateway to expose this lambda to the world.