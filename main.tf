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