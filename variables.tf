variable "aws_region" {
  default = "us-east-1"
}

variable "lambda_config" {
  description = "Configuration for the Lambda function"
  type = map(any)
  default = {
    name         = "lambda_cron_function"
    runtime      = "python3.9"
    handler      = "lambda_function.lambda_handler"
    timeout      = 30
    cron_schedule = "cron(0/5 * * * ? *)"
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {
    Environment = "Production"
    Team        = "DevOps"
  }
}

variable "s3_buckets" {
  description = "Map of S3 buckets for different purposes"
  type = map(string)
  default = {
    terraform_state = "my-terraform-state-bucket"
    lambda_code     = "my-lambda-code-bucket"
  }
}
