resource "aws_cloudwatch_metric_alarm" "scale_up" {
  alarm_name          = "auto_scaling_exercise_scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  threshold           = 1.5
  actions_enabled     = true
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]

  metric_query {
    id = "m"

    metric {
      period      = 60
      namespace   = "AWS/SQS"
      metric_name = "ApproximateNumberOfMessagesVisible"
      dimensions = {
        QueueName = aws_sqs_queue.task_queue.name
      }
      stat = "Average"
    }
  }

  metric_query {
    id = "w"

    metric {
      period      = 60
      namespace   = "AWS/AutoScaling"
      metric_name = "GroupInServiceInstances"
      dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.consumer.name
      }
      stat = "Average"
    }

  }

  metric_query {
    id          = "result"
    expression  = "IF(w != 0, CEIL(m/10)/w, IF(m > 0, 1.5, 1))"
    return_data = "true"
  }
}


resource "aws_cloudwatch_metric_alarm" "scale_in" {
  alarm_name          = "auto_scaling_exercise_scale_in"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  threshold           = 0.5
  actions_enabled     = true
  alarm_actions       = [aws_autoscaling_policy.scale_in.arn]

  metric_query {
    id = "m"

    metric {
      period      = 60
      namespace   = "AWS/SQS"
      metric_name = "ApproximateNumberOfMessagesVisible"
      dimensions = {
        QueueName = aws_sqs_queue.task_queue.name
      }
      stat = "Average"
    }
  }

  metric_query {
    id = "w"

    metric {
      period      = 60
      namespace   = "AWS/AutoScaling"
      metric_name = "GroupInServiceInstances"
      dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.consumer.name
      }
      stat = "Average"
    }
  }

  metric_query {
    id          = "result"
    expression  = "IF(w != 0, CEIL(m/10)/w, IF(m > 0, 1.5, 1))"
    return_data = "true"
  }
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "auto_scaling_exercise_scale_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = aws_autoscaling_group.consumer.name
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "auto_scaling_exercise_scale_in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = aws_autoscaling_group.consumer.name
}