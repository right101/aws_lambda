# S3 bucket for Lambda code
resource "aws_s3_bucket" "lambda_code" {
  bucket = var.s3_buckets["lambda_code"]
}

resource "aws_s3_bucket_acl" "lambda_code_acl" {
  bucket = aws_s3_bucket.lambda_code.id
  acl    = "private"
}

resource "aws_s3_object" "lambda_code_object" {
  bucket = var.s3_buckets["lambda_code"]
  key    = "lambda_function.zip"
  source = "lambda_function.zip"
}

# Lambda IAM role
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_execution_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda function
resource "aws_lambda_function" "lambda_cron" {
  function_name = var.lambda_config["name"]
  s3_bucket     = var.s3_buckets["lambda_code"]
  s3_key        = aws_s3_object.lambda_code_object.id
  runtime       = var.lambda_config["runtime"]
  handler       = var.lambda_config["handler"]
  role          = aws_iam_role.lambda_execution_role.arn
  timeout       = var.lambda_config["timeout"]
}

# CloudWatch Event Rule
resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  name                = "lambda_cron_schedule"
  description         = "Triggers Lambda every 5 minutes"
  schedule_expression = "cron(0/5 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_schedule.name
  target_id = "lambda"
  arn       = aws_lambda_function.lambda_cron.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_cron.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule.arn
}
