variable "aws_region" {
  default = "us-east-1"
}

variable "lambda_config" {
  description = "Configuration for the Lambda function"
  type        = map(any)
  default = {
    name    = "lambda_cron_function"
    runtime = "python3.9"
    handler = "lambda_function.lambda_handler"
    timeout = 30
  }
}

variable "s3_buckets" {
  description = "Map of S3 buckets for Terraform and Lambda"
  type        = map(string)
  default = {
    terraform_state = "right101-terraform-state-bucket"
    lambda_code     = "right101-lambda-code-bucket"
  }
}