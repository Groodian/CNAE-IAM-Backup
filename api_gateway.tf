resource "aws_apigatewayv2_api" "cnae_gateway" {
  name          = "cnae-api"
  protocol_type = "HTTP"
}

resource "aws_cloudwatch_log_group" "cnae_gateway_log" {
  name = "/aws/api-gateway/${aws_apigatewayv2_api.cnae_gateway.name}"

  retention_in_days = 30
}

resource "aws_apigatewayv2_authorizer" "cnae_auth" {
  api_id           = aws_apigatewayv2_api.cnae_gateway.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "cognito-authorizer"

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.cnae_user_pool_client.id]
    issuer   = "https://${aws_cognito_user_pool.cnae_user_pool.endpoint}"
  }
}

resource "aws_apigatewayv2_stage" "cnae_stage" {
  api_id      = aws_apigatewayv2_api.cnae_gateway.id
  name        = "dev"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "example_api_integration" {
  api_id             = aws_apigatewayv2_api.cnae_gateway.id
  integration_type   = "AWS_PROXY"
  connection_type    = "INTERNET"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.lambda_test.invoke_arn
}

resource "aws_apigatewayv2_route" "route" {
  api_id             = aws_apigatewayv2_api.cnae_gateway.id
  route_key          = "GET example"
  target             = "integrations/${aws_apigatewayv2_integration.example_api_integration.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cnae_auth.id
}
