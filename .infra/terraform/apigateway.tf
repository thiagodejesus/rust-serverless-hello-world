resource "aws_apigatewayv2_api" "this" {
  name        = var.project_name
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "default" {  
  api_id      = aws_apigatewayv2_api.this.id  
  name        = "$default"  
  auto_deploy = true  
  description = "Default stage (i.e., Production mode)"  
  default_route_settings {  
    throttling_burst_limit = 1  
    throttling_rate_limit  = 1  
  }  
  access_log_settings {  
    destination_arn = aws_cloudwatch_log_group.api_gateway_logs_hello.arn  
    format = jsonencode({  
      authorizerError           = "$context.authorizer.error",  
      identitySourceIP          = "$context.identity.sourceIp",  
      integrationError          = "$context.integration.error",  
      integrationErrorMessage   = "$context.integration.errorMessage"  
      integrationLatency        = "$context.integration.latency",  
      integrationRequestId      = "$context.integration.requestId",  
      integrationStatus         = "$context.integration.integrationStatus",  
      integrationStatusCode     = "$context.integration.status",  
      requestErrorMessage       = "$context.error.message",  
      requestErrorMessageString = "$context.error.messageString",  
      requestId                 = "$context.requestId",  
      routeKey                  = "$context.routeKey",  
    })   
  }  
}

resource "aws_api_gateway_account" "this" {  
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch_logs.arn  
}  
  
resource "aws_iam_role" "api_gateway_cloudwatch_logs" {  
  name = "api-gateway-cloudwatch-logs"  
  assume_role_policy = jsonencode({  
    Version = "2012-10-17"  
    Statement = [  
      {  
        Effect = "Allow"  
        Principal = {  
          Service = "apigateway.amazonaws.com"  
        }  
        Action = "sts:AssumeRole"  
      }  
    ]  
  })  
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"]  
}  
  
resource "aws_cloudwatch_log_group" "api_gateway_logs_hello" {  
  name              = "/aws/apigateway/hello"  
  log_group_class   = "STANDARD"  
  retention_in_days = 7  
}

# resource "aws_apigatewayv2_deployment" "example" {
#   api_id      = aws_apigatewayv2_api.this.id
#   description = "Example deployment"

#   triggers = {
#     redeployment = sha1(join(",", tolist([
#       jsonencode(aws_apigatewayv2_integration.example),
#       jsonencode(aws_apigatewayv2_route.example),
#     ])))
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }
