# resource "aws_api_gateway_http_api" "hello_world" {
#   name        = "HelloWorld"
#   description = "This is a simple API"
# }

# # resource "aws_api_gateway_resource" "root" {  
# #   http_api_id = aws_api_gateway_http_api.hello_world.id
# #   parent_id = aws_api_gateway_http_api.hello_world.root_resource_id
# #   path_part = ""
# # }

# # resource "aws_api_gateway_method" "proxy" {
# #   http_api_id = aws_api_gateway_http_api.hello_world.id
# #   resource_id = aws_api_gateway_resource.root.id
# #   http_method = "GET"
# #   authorization = "NONE"
# # }
