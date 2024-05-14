# How to create an aws rust lambda behind an api gateway and deploy it using docker and terraform

Why

- Rust
    As I like Rust for its emphasis on safety, I'm enjoying make some projects in it.
- Serverless
    I think that is a simpler way to deploy some experimental projects, at least, to start my journey.
- Docker
    Well, to learn how we can use docker to have more flexibility around the aws runtime on lambda.
- Terraform
    IaC (Infrastructure as code) its better than setup deploys using aws interface, as with it i can have versioning, and reproducibility, i choose terraform because its a very famous way to do it.

Requirements

- Cargo Lambda
    Cargo lambda its a cli developed by aws to help the development of serverless rust
    

Create the lambda

```sh
cargo lambda new --http rust-lambda-gw-api
```

The flag --http is to create a lambda that will receive http requests from an api gateway

The command above should create a new rust project with the below code on the main.rs

```rs
use lambda_http::{run, service_fn, tracing, Body, Error, Request, RequestExt, Response};

async fn function_handler(event: Request) -> Result<Response<Body>, Error> {
    let who = event
        .query_string_parameters_ref()
        .and_then(|params| params.first("name"))
        .unwrap_or("world");
    let message = format!("Hello {who}, this is an AWS Lambda HTTP request");

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

For this, we just gonna make a little change to the template:

```rs
...

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

...
```

Its a simple code that extracts the param `name` for the query, or default its value to world. Then we create or message and build the Response to send it to the Api Gateway.

Now, our function is ready, we can run it with `cargo lambda watch` then make a test request with `curl http://localhost:9000/\?name\="Wilson"` to receive our Hello Wilson.
