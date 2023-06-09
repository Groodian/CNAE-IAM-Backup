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

resource "aws_apigatewayv2_api_mapping" "cnae_mapping" {
  api_id      = aws_apigatewayv2_api.cnae_gateway.id
  domain_name = aws_apigatewayv2_domain_name.api.id
  stage       = aws_apigatewayv2_stage.cnae_stage.id
}

resource "aws_apigatewayv2_api_mapping" "cnae_mapping_dev" {
  api_id          = aws_apigatewayv2_api.cnae_gateway.id
  domain_name     = aws_apigatewayv2_domain_name.api.id
  stage           = aws_apigatewayv2_stage.cnae_stage.id
  api_mapping_key = "dev"
}

resource "aws_security_group" "vpc_link" {
  name   = "api-gateway_vpc-link"
  vpc_id = data.terraform_remote_state.infrastructure_state.outputs.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_apigatewayv2_integration" "test_integration" {
  api_id             = aws_apigatewayv2_api.cnae_gateway.id
  integration_type   = "AWS_PROXY"
  connection_type    = "INTERNET"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.lambda_test.invoke_arn
}

resource "aws_apigatewayv2_route" "test_route" {
  api_id             = aws_apigatewayv2_api.cnae_gateway.id
  route_key          = "GET /example"
  target             = "integrations/${aws_apigatewayv2_integration.test_integration.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cnae_auth.id
}

resource "aws_apigatewayv2_vpc_link" "eks_link" {
  name               = "eks-link"
  security_group_ids = [aws_security_group.vpc_link.id]
  subnet_ids         = data.terraform_remote_state.infrastructure_state.outputs.subnet_private_ids
}
