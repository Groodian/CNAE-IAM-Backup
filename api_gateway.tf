resource "aws_api_gateway_rest_api" "cnae_gateway" {
  name = "example-api"
}

resource "aws_cloudwatch_log_group" "cnae_gateway_log" {
  name = "/aws/api-gateway/${aws_api_gateway_rest_api.cnae_gateway.name}"

  retention_in_days = 30
}

resource "aws_api_gateway_deployment" "cnae_gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.cnae_gateway.id
  stage_name  = "dev"

  depends_on = [ aws_api_gateway_integration.example_api_integration ]
}

resource "aws_api_gateway_resource" "example_resource" {
  rest_api_id = aws_api_gateway_rest_api.cnae_gateway.id
  parent_id   = aws_api_gateway_rest_api.cnae_gateway.root_resource_id
  path_part   = "example"
}

resource "aws_api_gateway_method" "example_api_method" {
  rest_api_id   = aws_api_gateway_rest_api.cnae_gateway.id
  resource_id   = aws_api_gateway_resource.example_resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.api_authorizer.id

  request_parameters = {
    "method.request.path.proxy" = true,
  }
}

resource "aws_api_gateway_integration" "example_api_integration" {
  rest_api_id             = aws_api_gateway_rest_api.cnae_gateway.id
  resource_id             = aws_api_gateway_resource.example_resource.id
  http_method             = aws_api_gateway_method.example_api_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_test.invoke_arn
}

resource "aws_api_gateway_method_response" "example_in_method_response" {
  for_each    = toset(["200", "500"])
  rest_api_id = aws_api_gateway_rest_api.cnae_gateway.id
  resource_id = aws_api_gateway_resource.example_resource.id
  http_method = aws_api_gateway_method.example_api_method.http_method
  status_code = each.value
}

resource "aws_api_gateway_authorizer" "api_authorizer" {
  name          = "CognitoUserPoolAuthorizer"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.cnae_gateway.id
  provider_arns = [aws_cognito_user_pool.cnae_user_pool.arn]
}
