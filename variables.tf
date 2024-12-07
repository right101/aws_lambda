variable "aws_region" {
  default = "us-east-1"
}

variable "bucket_config" {
  description = "Map of S3 buckets for Terraform state and Lambda code"
  type        = map(string)
}

variable "lambda_config" {
  description = "Lambda function configuration"
  type = object({
    function_name    = string
    runtime          = string
    handler          = string
    timeout          = number
    schedule_name    = string
    schedule_cron    = string
    environment_vars = map(string) 
  })
}

