resource "aws_lambda_function" "lambda_test" {
  function_name = "lambda-test"

  filename = "${path.module}/lambda/test/test.zip"
  role     = aws_iam_role.lambda_exec.arn

  runtime = "nodejs18.x"
  handler = "test.handler"

  source_code_hash = data.archive_file.lambda_test_zip.output_base64sha256

  depends_on = [aws_iam_role_policy_attachment.lambda_policy_attachment]
}

resource "aws_lambda_function" "lambda_pre_sign_up" {
  function_name = "lambda-pre-sign-up"

  filename = "${path.module}/lambda/pre_sign_up/pre_sign_up.zip"
  role     = aws_iam_role.lambda_exec.arn

  runtime = "nodejs18.x"
  handler = "pre_sign_up.handler"

  source_code_hash = data.archive_file.lambda_pre_sign_up_zip.output_base64sha256

  depends_on = [aws_iam_role_policy_attachment.lambda_policy_attachment]
}

resource "aws_lambda_function" "lambda_post_sign_up" {
  function_name = "lambda-post-sign-up"

  filename = "${path.module}/lambda/post_sign_up/post_sign_up.zip"
  role     = aws_iam_role.lambda_exec.arn

  runtime = "nodejs18.x"
  handler = "post_sign_up.handler"

  source_code_hash = data.archive_file.lambda_post_sign_up_zip.output_base64sha256

  depends_on = [aws_iam_role_policy_attachment.lambda_policy_attachment]
}

data "archive_file" "lambda_test_zip" {
  type = "zip"

  source_dir  = "${path.module}/lambda/test"
  output_path = "${path.module}/lambda/test/test.zip"
}

data "archive_file" "lambda_pre_sign_up_zip" {
  type = "zip"

  source_dir  = "${path.module}/lambda/pre_sign_up"
  output_path = "${path.module}/lambda/pre_sign_up/pre_sign_up.zip"
}

data "archive_file" "lambda_post_sign_up_zip" {
  type = "zip"

  source_dir  = "${path.module}/lambda/post_sign_up"
  output_path = "${path.module}/lambda/post_sign_up/post_sign_up.zip"
}

resource "aws_cloudwatch_log_group" "lambda_test_log" {
  name = "/aws/lambda/${aws_lambda_function.lambda_test.function_name}"

  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "lambda_pre_sign_up_log" {
  name = "/aws/lambda/${aws_lambda_function.lambda_pre_sign_up.function_name}"

  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "lambda_post_sign_up_log" {
  name = "/aws/lambda/${aws_lambda_function.lambda_post_sign_up.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda-test"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_exec_cognito" {
  role = aws_iam_role.lambda_exec.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = "cognito-idp:AdminAddUserToGroup"
      Effect   = "Allow"
      Sid      = ""
      Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_permission" "lambda_test_permission_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_test.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.cnae_gateway.execution_arn}/*/*"
}

resource "aws_lambda_permission" "lambda_pre_sign_up_permission_cognito" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_pre_sign_up.function_name
  principal     = "cognito-idp.amazonaws.com"

  source_arn = aws_cognito_user_pool.cnae_user_pool.arn
}

resource "aws_lambda_permission" "lambda_post_sign_up_permission_cognito" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_post_sign_up.function_name
  principal     = "cognito-idp.amazonaws.com"

  source_arn = aws_cognito_user_pool.cnae_user_pool.arn
}
