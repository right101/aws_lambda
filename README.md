# Automated Deployment of AWS Lambda with Terraform and Scheduled Trigger
## Overview

This project simplifies the deployment of an AWS Lambda function triggered by a scheduled CloudWatch Event Rule, using Terraform for infrastructure as code (IaC). The setup includes an automated script that handles Terraform backend creation, initialization, and resource deployment.

The Lambda function's code is dynamically generated, zipped, and uploaded to an S3 bucket, while Terraform manages all associated resources, including IAM Roles, S3 buckets, and CloudWatch Events. This ensures a scalable and reusable workflow for managing serverless infrastructure with robust automation and error handling.


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
