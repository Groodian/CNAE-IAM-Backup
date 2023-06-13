output "api_gateway_url" {
  value = aws_apigatewayv2_stage.cnae_stage.invoke_url
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.cnae_user_pool.id
}

output "cognito_user_pool_client_id" {
  value = aws_cognito_user_pool_client.cnae_user_pool_client.id
}

output "cognito_user_pool_client_url" {
  value = "https://${aws_cognito_user_pool_domain.cnae_user_pool_domain.domain}.auth.eu-central-1.amazoncognito.com/"
}

output "api_gateway_id" {
  value = aws_apigatewayv2_api.cnae_gateway.id
}

output "api_gateway_eks_link_id" {
  value = aws_apigatewayv2_vpc_link.eks_link.id
}

output "api_gateway_authorizer" {
  value = aws_apigatewayv2_authorizer.cnae_auth.id
}
