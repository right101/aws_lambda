output "lambda_function_arn" {
  value = module.lambda_cron.lambda_function_arn
}

output "cloudwatch_event_rule" {
  value       = aws_cloudwatch_event_rule.lambda_schedule.name
  description = "The name of the CloudWatch event rule that triggers the Lambda function."
}
