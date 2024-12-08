
resource "aws_sqs_queue" "task_queue" {
  name                       = "auto_scaling_exercise_tasks"
  visibility_timeout_seconds = 120
}
