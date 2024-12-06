#!/bin/bash

# Variables
STATE_BUCKET="right101-terraform-state-bucket"  # S3 bucket for Terraform state
REGION="us-east-1"                              # AWS region
LAMBDA_ZIP_FILE="lambda_function.zip"           # Lambda ZIP file name

# Function to check the status of the last command
check_status() {
  if [ $? -ne 0 ]; then
    echo "Error: $1"
    exit 1
  fi
}

# Check if the S3 bucket for Terraform state exists
echo "Checking if S3 bucket '$STATE_BUCKET' exists..."
if ! aws s3api head-bucket --bucket "$STATE_BUCKET" 2>/dev/null; then
  echo "Bucket '$STATE_BUCKET' does not exist. Creating..."
  if [ "$REGION" == "us-east-1" ]; then
    aws s3api create-bucket --bucket "$STATE_BUCKET"
  else
    aws s3api create-bucket --bucket "$STATE_BUCKET" --region "$REGION" \
      --create-bucket-configuration LocationConstraint="$REGION"
  fi
  aws s3api put-bucket-versioning --bucket "$STATE_BUCKET" --versioning-configuration Status=Enabled
  check_status "Failed to create or configure the S3 bucket for state."
else
  echo "Bucket '$STATE_BUCKET' already exists."
fi

# Ensure the Lambda ZIP file exists
if [ ! -f "$LAMBDA_ZIP_FILE" ]; then
  echo "Lambda ZIP file '$LAMBDA_ZIP_FILE' not found. Please create it before running this script."
  exit 1
fi

# Format Terraform files
echo "Formatting Terraform configuration..."
terraform fmt -recursive
check_status "Terraform formatting failed."

# Initialize Terraform
echo "Initializing Terraform..."
terraform init
check_status "Terraform initialization failed."

# Validate Terraform configuration
echo "Validating Terraform configuration..."
terraform validate
check_status "Terraform validation failed."

# Generate and show Terraform plan
echo "Planning Terraform configuration..."
terraform plan -out=tfplan
check_status "Terraform plan failed."

# Prompt for user confirmation before applying
read -p "Do you want to apply Terraform changes? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
  echo "Terraform apply canceled."
  exit 0
fi

# Apply the Terraform plan
echo "Applying Terraform configuration..."
terraform apply tfplan
check_status "Terraform apply failed."

# Cleanup the plan file
rm -f tfplan
echo "Terraform apply completed successfully."