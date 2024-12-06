variable "aws_region" {
  default = "us-east-1"
}

variable "s3_buckets" {
  description = "Map of S3 buckets for Terraform state and Lambda code"
  type        = map(string)
  default = {
    terraform_state = "right101-terraform-state-bucket"
    lambda_code     = "right101-lambda-code-bucket"
  }
}

variable "lambda_config" {
  description = "Map of Lambda function configuration"
  type        = map(any)
  default = {
    function_name = "lambda_cron_function"
    runtime       = "python3.9"
    handler       = "lambda_function.lambda_handler"
    code_file     = "lambda_function.zip"
    s3_key        = "lambda_function.zip"
    schedule_name = "lambda_cron_schedule"
    schedule_cron = "cron(0/5 * * * ? *)"
  }
}
