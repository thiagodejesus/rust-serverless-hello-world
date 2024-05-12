# How to create an aws rust lambda behind an api gateway and deploy it using docker and terraform

Why
  - Rust
  - Serverless
  - Docker
  - Terraform

Requirements
  - Cargo Lambda

Create the lambda
```sh
cargo lambda new --http rust-lambda-gw-api
```

The flag --http is to create a lambda that will receive http requests from an api gateway

The command above should create a new rust project with the below code on the main.rs

```rs
use lambda_http::{run, service_fn, tracing, Body, Error, Request, RequestExt, Response};

/// This is the main body for the function.
/// Write your code inside it.
/// There are some code example in the following URLs:
/// - https://github.com/awslabs/aws-lambda-rust-runtime/tree/main/examples
async fn function_handler(event: Request) -> Result<Response<Body>, Error> {
    // Extract some useful information from the request
    let who = event
        .query_string_parameters_ref()
        .and_then(|params| params.first("name"))
        .unwrap_or("world");
    let message = format!("Hello {who}, this is an AWS Lambda HTTP request");

    // Return something that implements IntoResponse.
    // It will be serialized to the right response event automatically by the runtime
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

Now we are going to replace the function_handler with our logic, for this tutorial, we gonna expose a get route that Receives a name as query param and returns Hello {name}!