
resource "aws_cloudwatch_event_rule" "producer_schedule" {
  name                = "auto_scaling_exercise_producer_schedule"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "producer_target" {
  rule      = aws_cloudwatch_event_rule.producer_schedule.name
  target_id = "auto_scaling_exercise_producer"
  arn       = aws_lambda_function.producer.arn
}

resource "aws_lambda_permission" "producer_target" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.producer.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.producer_schedule.arn
}