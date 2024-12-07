# Automated Deployment of AWS Lambda with Terraform and Scheduled Trigger
## Overview

This project simplifies the deployment of an AWS Lambda function triggered by a scheduled CloudWatch Event Rule, using Terraform for infrastructure as code (IaC). The setup includes an automated script that handles Terraform backend creation, initialization, and resource deployment.

The Lambda function's code is dynamically generated, zipped, and uploaded to an S3 bucket, while Terraform manages all associated resources, including IAM Roles, S3 buckets, and CloudWatch Events. This ensures a scalable and reusable workflow for managing serverless infrastructure with robust automation and error handling.


---

## Features

- **AWS Lambda Deployment**: Automatically create, configure, and deploy an AWS Lambda function.
- **CloudWatch Event Scheduling**: Trigger the Lambda function every 5 minutes using CloudWatch Event Rules.
- **Dynamic Code Management**: Dynamically generate, zip, and upload the Lambda function code to an S3 bucket.
- **S3 Backend Integration**: Store Terraform state in a dedicated S3 bucket for reliable infrastructure management.
- **Lambda Code Storage**: Store the zipped Lambda function code in a separate S3 bucket (`lambda_code`) for deployment.
- **Automated Script**: Automate backend S3 bucket creation, Terraform initialization, planning, application, and destruction.
- **Output Management**: Display key outputs such as Lambda ARN and CloudWatch Event Rule name after deployment.

---

## Prerequisites

1. **AWS CLI** installed and configured with the appropriate credentials.
2. **Terraform** installed (version >= 1.0.0).
3. **Custom Variables File**: Create a `custom.tfvars` file with the required configuration values (example provided below).

---

## Setup Instructions

### Step 1: Configure the Terraform State Bucket
Ensure the S3 bucket for storing Terraform state is created using the script:

```bash
./setup-bucket-and-run.sh
