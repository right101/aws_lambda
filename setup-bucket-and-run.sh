#!/bin/bash

# Variables
STATE_BUCKET="right101-terraform-state-bucket"  # S3 bucket for Terraform state
TF_VARS_FILE="custom.tfvars"                    # Terraform variables file
REGION="us-east-1"                              # AWS region

# Function to check the status of the last command
check_status() {
  if [ $? -ne 0 ]; then
    echo "Error: $1"
    exit 1
  fi
}

# Function to create S3 bucket if it doesn't exist
create_s3_bucket() {
  local bucket_name=$1
  local region=$2

  echo "Checking if S3 bucket '$bucket_name' exists..."
  if ! aws s3api head-bucket --bucket "$bucket_name" 2>/dev/null; then
    echo "Bucket '$bucket_name' does not exist. Creating..."
    if [ "$region" == "us-east-1" ]; then
      aws s3api create-bucket --bucket "$bucket_name"
    else
      aws s3api create-bucket --bucket "$bucket_name" --region "$region" \
        --create-bucket-configuration LocationConstraint="$region"
    fi
    aws s3api put-bucket-versioning --bucket "$bucket_name" --versioning-configuration Status=Enabled
    check_status "Failed to create or configure the S3 bucket '$bucket_name'."
  else
    echo "Bucket '$bucket_name' already exists."
  fi
}

# Create the state bucket
create_s3_bucket "$STATE_BUCKET" "$REGION"

# Run Terraform commands
echo "Running Terraform commands with variables from $TF_VARS_FILE..."

# Initialize Terraform
terraform init
check_status "Terraform initialization failed."

# Format Terraform files
terraform fmt -recursive
check_status "Terraform formatting failed."

# Validate Terraform configuration
terraform validate
check_status "Terraform validation failed."

# Generate and show Terraform plan using custom.tfvars
terraform plan -var-file="$TF_VARS_FILE" -out=tfplan
check_status "Terraform plan failed."

# Prompt for user confirmation before applying
read -p "Do you want to apply Terraform changes? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
  echo "Terraform apply canceled."
  exit 0
fi

# Apply the Terraform plan
terraform apply tfplan
check_status "Terraform apply failed."

# Cleanup the plan file
rm -f tfplan
echo "Terraform apply completed successfully."
