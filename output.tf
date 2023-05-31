output "api_gateway_url" {
  value = aws_api_gateway_deployment.cnae_gateway_deployment.invoke_url
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.cnae_user_pool.id
}

output "cognito_user_pool_client_id" {
  value = aws_cognito_user_pool_client.cnae_user_pool_client.id
}
