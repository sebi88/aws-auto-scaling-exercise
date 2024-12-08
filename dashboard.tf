resource "aws_cloudwatch_dashboard" "dashboard" {
  dashboard_name = "auto_scaling_exercise"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 9
        properties = {
          metrics = [
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", aws_sqs_queue.task_queue.name],
            ["AWS/AutoScaling", "GroupInServiceInstances", "AutoScalingGroupName", aws_autoscaling_group.consumer.name, { "yAxis" : "right" }]
          ]
          period  = 60
          region  = data.aws_region.current.name
          stacked = false
          view    = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 9
        width  = 12
        height = 9
        properties = {
          metrics = [
            ["AWS/SQS", "NumberOfMessagesSent", "QueueName", aws_sqs_queue.task_queue.name],
            ["AWS/SQS", "NumberOfMessagesDeleted", "QueueName", aws_sqs_queue.task_queue.name]
          ]
          period  = 60
          region  = data.aws_region.current.name
          stacked = false
          stat    = "Sum"
          view    = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 9
        properties = {
          title = "Scale up"
          annotations = {
            alarms = [
              aws_cloudwatch_metric_alarm.scale_up.arn
            ]
          }
          stacked = false
          view    = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 9
        width  = 12
        height = 9
        properties = {
          title = "Scale in"
          annotations = {
            alarms = [
              aws_cloudwatch_metric_alarm.scale_in.arn
            ]
          }
          stacked = false
          view    = "timeSeries"
        }
      }
    ]
  })
}