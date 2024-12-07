# Automated Deployment of AWS Lambda with Terraform and Scheduled Trigger

This project demonstrates how to deploy an AWS Lambda function using Terraform, with the function's code dynamically generated and scheduled to run every 5 minutes using AWS CloudWatch Event Rules.

## Features

- **AWS Lambda Deployment**: Automatically create an AWS Lambda function.
- **Terraform Integration**: Use Terraform for infrastructure as code.
- **CloudWatch Event Trigger**: Schedule the Lambda function to execute every 5 minutes.
- **Dynamic Code Generation**: Generate and deploy the Lambda function code dynamically using Terraform.
- **S3 Backend Configuration**: Use an S3 bucket for Terraform state management.

## Prerequisites

Before running the project, ensure the following tools and configurations are in place:

1. **AWS CLI** installed and configured with the appropriate credentials.
2. **Terraform** installed (version >= 1.0.0).
3. AWS IAM permissions for managing Lambda, CloudWatch, S3, and IAM resources.
4. A working `custom.tfvars` file for custom variable values (see example below).

## Setup Instructions

### Step 1: Configure the Terraform State Bucket
Ensure the S3 bucket for storing Terraform state is created using the script:

```bash
./setup-bucket-and-run.sh
