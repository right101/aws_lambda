# S3 bucket for Lambda code
resource "aws_s3_bucket" "lambda_code" {
  bucket        = var.bucket_config["lambda_code"]
  force_destroy = true
}
resource "aws_s3_bucket_versioning" "lambda_code_versioning" {
  bucket = aws_s3_bucket.lambda_code.id
  versioning_configuration {
    status = "Enabled"
  }
}
# Generate Lambda function code dynamically
resource "local_file" "lambda_code" {
  content  = <<EOF
def lambda_handler(event, context):
    print("Hello! Lambda function triggered by CloudWatch Events.")
    return {"statusCode": 200, "body": "Lambda executed successfully!"}
EOF
  filename = "${path.module}/lambda_function.py"
}

# Archive the Lambda code into a ZIP file
resource "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = local_file.lambda_code.filename
  output_path = "${path.module}/lambda_function.zip"
}

# Upload the Lambda ZIP to the S3 bucket
resource "aws_s3_object" "lambda_zip" {
  bucket = aws_s3_bucket.lambda_code.id
  key    = "lambda_function.zip"
  source = archive_file.lambda_zip.output_path
  etag   = filemd5(archive_file.lambda_zip.output_path)
}

resource "aws_lambda_function" "lambda_cron" {
  function_name = var.lambda_config["function_name"]
  s3_bucket     = aws_s3_bucket.lambda_code.id
  s3_key        = aws_s3_object.lambda_code.key
  handler       = var.lambda_config["handler"]
  runtime       = var.lambda_config["runtime"]
  timeout       = var.lambda_config["timeout"]

  environment {
    variables = var.lambda_config["environment_vars"]
  }
}

# CloudWatch Event Rule to trigger Lambda every 5 minutes
resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  name                = var.lambda_config["schedule_name"]
  description         = "Triggers Lambda every 5 minutes"
  schedule_expression = var.lambda_config["schedule_cron"]
}

# CloudWatch Event Target linking the Event Rule to the Lambda function
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_schedule.name
  target_id = "lambda"
  arn       = aws_lambda_function.lambda_cron.arn
}

# Grant CloudWatch Events permission to invoke the Lambda function
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_cron.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule.arn
}
