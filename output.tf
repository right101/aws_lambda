output "lambda_function_arn" {
  value       = aws_lambda_function.lambda_cron.arn
  description = "The ARN of the deployed Lambda function."
}

output "cloudwatch_event_rule" {
  value       = aws_cloudwatch_event_rule.lambda_schedule.name
  description = "The name of the CloudWatch event rule that triggers the Lambda function."
}
