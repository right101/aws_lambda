output "lambda_function_arn" {
  value = aws_lambda_function.lambda_cron.arn
}

output "cloudwatch_event_rule" {
  value = aws_cloudwatch_event_rule.lambda_schedule.name
}
