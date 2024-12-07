# Output the ARN of the Lambda function
output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.lambda_cron.arn
}

# Output the CloudWatch Event Rule name
output "cloudwatch_event_rule" {
  description = "Name of the CloudWatch Event Rule triggering the Lambda"
  value       = aws_cloudwatch_event_rule.lambda_schedule.name
}
