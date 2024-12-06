terraform {
  backend "s3" {
    bucket = "right101-terraform-state-bucket"
    key    = "lambda-cron/terraform.tfstate"
    region = "us-east-1"
  }
}
