terraform {
  backend "s3" {
    bucket = aws_s3_bucket.terraform_state.bucket
    key    = "lambda-cron/terraform.tfstate"
    region = "us-east-1"
  }
}
