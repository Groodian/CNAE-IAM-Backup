resource "aws_lambda_function" "lambda_test" {
  function_name = "lambda-test"

  filename = "${path.module}/test_lambda/test.zip"
  role     = aws_iam_role.lambda_exec.arn

  runtime = "nodejs18.x"
  handler = "test.handler"

  source_code_hash = data.archive_file.lambda_test_zip.output_base64sha256

  depends_on = [aws_iam_role_policy_attachment.lambda_policy_attachment]
}

data "archive_file" "lambda_test_zip" {
  type = "zip"

  source_dir  = "${path.module}/test_lambda/"
  output_path = "${path.module}/test_lambda/test.zip"
}

resource "aws_cloudwatch_log_group" "lambda_test_log" {
  name = "/aws/lambda/${aws_lambda_function.lambda_test.function_name}"

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

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_permission" "lambda_test_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_test.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.cnae_gateway.execution_arn}/*/*"
}
