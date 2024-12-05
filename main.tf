# S3 Bucket for Terraform State
resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-bucket-right101"
  acl    = "private"
}

# Enable Versioning for the S3 Bucket
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket for Lambda Code
resource "aws_s3_bucket" "lambda_code" {
  bucket = "lambda-code-bucket-unique-name"
  acl    = "private"
}

resource "aws_s3_bucket_object" "lambda_code_object" {
  bucket = aws_s3_bucket.lambda_code.id
  key    = "lambda_function.zip"
  source = "lambda_function.zip"
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_execution_role" {
  name               = "lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_logs" {
  name       = "lambda_logs_policy"
  roles      = [aws_iam_role.lambda_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Function
resource "aws_lambda_function" "lambda_cron" {
  function_name    = "lambda_cron_function"
  s3_bucket        = aws_s3_bucket.lambda_code.id
  s3_key           = aws_s3_bucket_object.lambda_code_object.key
  runtime          = "python3.9"
  handler          = "lambda_function.lambda_handler"
  role             = aws_iam_role.lambda_execution_role.arn
  timeout          = 30
  source_code_hash = filebase64sha256("lambda_function.zip")
}

# CloudWatch Event Rule
resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  name                = "lambda_cron_schedule"
  description         = "Triggers Lambda every 5 minutes"
  schedule_expression = "cron(0/5 * * * ? *)"
}

# CloudWatch Event Target
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_schedule.name
  target_id = "lambda"
  arn       = aws_lambda_function.lambda_cron.arn
}

# Permission for CloudWatch to Trigger Lambda
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_cron.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule.arn
}