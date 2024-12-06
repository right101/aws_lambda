#!/bin/bash

# Variables
BUCKET_NAME="right101-terraform-state-bucket"  # Your bucket name
REGION="us-east-1"                            # Your desired region
DRY_RUN=false                                 # Enable dry-run mode for testing

# Function to check the status of the last command and exit on failure
check_status() {
  if [ $? -ne 0 ]; then
    echo "Error: $1"
    exit 1
  fi
}

# Check if dry-run mode is enabled
if $DRY_RUN; then
  echo "Dry-run mode enabled. No changes will be made."
  exit 0
fi

# Check if the S3 bucket exists
echo "Checking if S3 bucket '$BUCKET_NAME' exists..."
if ! aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
  echo "Bucket '$BUCKET_NAME' does not exist. Creating..."
  if [ "$REGION" == "us-east-1" ]; then
    aws s3api create-bucket --bucket "$BUCKET_NAME"
    check_status "Failed to create bucket '$BUCKET_NAME' in region '$REGION'."
  else
    aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION" \
      --create-bucket-configuration LocationConstraint="$REGION"
    check_status "Failed to create bucket '$BUCKET_NAME' in region '$REGION'."
  fi
  aws s3api put-bucket-versioning --bucket "$BUCKET_NAME" --versioning-configuration Status=Enabled
  check_status "Failed to enable versioning for bucket '$BUCKET_NAME'."
  echo "Bucket '$BUCKET_NAME' created and versioning enabled."
else
  echo "Bucket '$BUCKET_NAME' already exists."
fi

# Format Terraform configuration
echo "Formatting Terraform configuration..."
terraform fmt -recursive
check_status "Terraform formatting failed."

# Initialize Terraform
echo "Initializing Terraform..."
terraform init
check_status "Terraform initialization failed."

# Plan Terraform configuration
echo "Planning Terraform configuration..."
terraform plan -out=tfplan
check_status "Terraform plan failed."

# Confirm before applying Terraform changes
read -p "Do you want to apply Terraform changes? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
  echo "Terraform apply canceled."
  exit 0
fi

# Apply Terraform configuration
echo "Applying Terraform configuration..."
terraform apply tfplan
check_status "Terraform apply failed."

# Cleanup the plan file
rm -f tfplan
echo "Terraform apply completed successfully."