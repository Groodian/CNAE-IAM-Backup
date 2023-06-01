resource "aws_cognito_user_pool" "cnae_user_pool" {
  name = "cnae-user-pool"

  lambda_config {
    pre_sign_up = aws_lambda_function.lambda_pre_sign_up.arn
  }
}

resource "aws_cognito_user_pool_client" "cnae_user_pool_client" {
  name         = "cnae-user-pool-client"
  user_pool_id = aws_cognito_user_pool.cnae_user_pool.id

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}

resource "aws_cognito_user_group" "admin_group" {
  name         = "admin"
  user_pool_id = aws_cognito_user_pool.cnae_user_pool.id
}

resource "aws_cognito_user_group" "professor_group" {
  name         = "professor"
  user_pool_id = aws_cognito_user_pool.cnae_user_pool.id
}

resource "aws_cognito_user_group" "student_group" {
  name         = "student"
  user_pool_id = aws_cognito_user_pool.cnae_user_pool.id
}
