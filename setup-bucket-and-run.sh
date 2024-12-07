#!/bin/bash

# Variables
STATE_BUCKET="right101-terraform-state-bucket"  # S3 bucket for Terraform state
REGION="us-east-1"                              # AWS region
TFVARS_FILE="custom.tfvars"                     # Custom variables file
BACKEND_FILE="backend.tf"                       # Terraform backend configuration file

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

# Create the backend.tf file
echo "Creating Terraform backend configuration file ($BACKEND_FILE)..."
cat <<EOF > $BACKEND_FILE
terraform {
  backend "s3" {
    bucket = "$STATE_BUCKET"
    key    = "lambda-cron/terraform.tfstate"
    region = "$REGION"
  }
}
EOF
check_status "Failed to create backend configuration file."

# Initialize Terraform
echo "Initializing Terraform..."
terraform init
check_status "Terraform initialization failed."

# Prompt the user for the action to perform
echo "Choose an action: plan, apply, or destroy"
read -p "Enter your choice: " ACTION

if [ "$ACTION" == "plan" ]; then
  echo "Planning Terraform configuration..."
  terraform plan -var-file="$TFVARS_FILE" -out=tfplan
  check_status "Terraform plan failed."
  
  # Prompt the user for follow-up action
  echo "Do you want to apply the plan or destroy the infrastructure?"
  read -p "Enter 'apply' to apply the plan or 'destroy' to destroy the resources: " FOLLOW_UP_ACTION
  
  if [ "$FOLLOW_UP_ACTION" == "apply" ]; then
    echo "Applying Terraform configuration..."
    terraform apply tfplan
    check_status "Terraform apply failed."
  elif [ "$FOLLOW_UP_ACTION" == "destroy" ]; then
    echo "Destroying Terraform-managed infrastructure..."
    terraform destroy -var-file="$TFVARS_FILE"
    check_status "Terraform destroy failed."
  else
    echo "Invalid action specified. Exiting."
    exit 1
  fi

elif [ "$ACTION" == "apply" ]; then
  echo "Applying Terraform configuration..."
  terraform apply -var-file="$TFVARS_FILE"
  check_status "Terraform apply failed."

elif [ "$ACTION" == "destroy" ]; then
  echo "Destroying Terraform-managed infrastructure..."
  terraform destroy -var-file="$TFVARS_FILE"
  check_status "Terraform destroy failed."

else
  echo "Invalid action specified. Exiting."
  exit 1
fi
