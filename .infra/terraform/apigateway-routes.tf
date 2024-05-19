module "hello_world" {  
  source                = "./modules/api-gateway-route"  
  api_id                = aws_apigatewayv2_api.this.id  
  route_key             = "GET /"  
  api_gw_execution_arn  = aws_apigatewayv2_api.this.execution_arn  
  lambda_invocation_arn = module.serverless_rust_hello_world.lambda.invoke_arn  
  lambda_function_name  = module.serverless_rust_hello_world.lambda.function_name  
}