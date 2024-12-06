# S3 bucket for Terraform state (referenced in backend.tf)
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.s3_buckets["terraform_state"]
  versioning {
    enabled = true
  }
}

# S3 bucket for Lambda code
resource "aws_s3_bucket" "lambda_code" {
  bucket        = var.s3_buckets["lambda_code"]
  force_destroy = true
}

# Upload Lambda code to S3
resource "aws_s3_object" "lambda_code_object" {
  bucket = aws_s3_bucket.lambda_code.id
  key    = var.lambda_config["s3_key"]
  source = var.lambda_config["code_file"] # Ensure this file exists
}

# Use Anton Babenko's Lambda module
module "lambda_cron" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 5.0"

  function_name = var.lambda_config["function_name"]
  description   = "Lambda function triggered by CloudWatch Events every 5 minutes"

  s3_bucket = aws_s3_bucket.lambda_code.id
  s3_object_key    = aws_s3_object.lambda_code_object.key

  handler = var.lambda_config["handler"]
  runtime = var.lambda_config["runtime"]

  create_role = true
  allowed_triggers = {
    cloudwatch_event = {
      service = "events.amazonaws.com"
    }
  }

  environment_variables = {
    LOG_LEVEL = "INFO"
  }

  tags = {
    Environment = "Production"
    Project     = "LambdaCron"
  }
}

# CloudWatch Event Rule to trigger Lambda every 5 minutes
resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  name                = var.lambda_config["schedule_name"]
  description         = "Triggers Lambda every 5 minutes"
  schedule_expression = var.lambda_config["schedule_cron"]
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_schedule.name
  target_id = "lambda"
  arn       = module.lambda_cron.lambda_function_arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_cron.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule.arn
}