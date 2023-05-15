resource "aws_apigatewayv2_api" "example" {
  name          = "example-http-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "example" {
  api_id                 = aws_apigatewayv2_api.example.id
  integration_type       = "AWS_PROXY"
  payload_format_version = "2.0"
  description            = "Lambda example"
  integration_method     = "ANY"
  integration_uri        = aws_lambda_function.lambda.invoke_arn
}

resource "aws_apigatewayv2_route" "example" {
  api_id    = aws_apigatewayv2_api.example.id
  route_key = "ANY /example/{proxy+}"

  target = "integrations/${aws_apigatewayv2_integration.example.id}"
}

resource "aws_lambda_layer_version" "lambda_layer" {
  filename   = "${path.cwd}/lambda/lambda_layer_payload.zip"
  layer_name = "mylambda_layer_name"

  compatible_runtimes = ["python3.8"]
}

# data "archive_file" "lambda_archive" {
#   type        = "zip"
#   source_file = "${path.cwd}/lambda/main.py"
#   output_path = "${path.cwd}/lambda/lambda_function.zip"
# }

resource "aws_lambda_function" "lambda" {
  # instead of deploying the lambda from a zip file,
  # we can also deploy it using local code mounting
  s3_bucket = "hot-reload"
  s3_key    = "${path.cwd}/lambda"

  # filename      = data.archive_file.lambda_archive.output_path
  function_name = "mylambda"
  role          = aws_iam_role.role.arn
  handler       = "lambda.handler"

  # source_code_hash = data.archive_file.lambda_archive.output_base64sha256

  runtime       = "python3.8"

  environment {
    variables = {
      foo = "bar"
    }
  }
}

resource "aws_iam_role" "role" {
  name = "myrole"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}
