resource "aws_cognito_user" "admin_test_user" {
  user_pool_id = aws_cognito_user_pool.cnae_user_pool.id
  username     = "test-admin"
  password     = "Test123456!"
}

resource "aws_cognito_user_in_group" "admin_test_user" {
  user_pool_id = aws_cognito_user_pool.cnae_user_pool.id
  group_name   = aws_cognito_user_group.admin_group.name
  username     = aws_cognito_user.admin_test_user.username
}

resource "aws_cognito_user" "professor_test_user" {
  user_pool_id = aws_cognito_user_pool.cnae_user_pool.id
  username     = "test-professor"
  password     = "Test123456!"
}

resource "aws_cognito_user_in_group" "professor_test_user" {
  user_pool_id = aws_cognito_user_pool.cnae_user_pool.id
  group_name   = aws_cognito_user_group.professor_group.name
  username     = aws_cognito_user.professor_test_user.username
}

resource "aws_cognito_user" "student_test_user" {
  user_pool_id = aws_cognito_user_pool.cnae_user_pool.id
  username     = "test-student"
  password     = "Test123456!"
}

resource "aws_cognito_user_in_group" "student_test_user" {
  user_pool_id = aws_cognito_user_pool.cnae_user_pool.id
  group_name   = aws_cognito_user_group.student_group.name
  username     = aws_cognito_user.student_test_user.username
}
