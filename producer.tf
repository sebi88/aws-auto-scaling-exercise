
resource "aws_iam_policy" "producer" {
  name = "auto_scaling_exercise_producer"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["sqs:SendMessage"]
        Effect   = "Allow"
        Resource = aws_sqs_queue.task_queue.arn
      },
    ]
  })
}

resource "aws_iam_role" "producer" {
  name                = "auto_scaling_exercise_producer"
  managed_policy_arns = [aws_iam_policy.producer.arn]
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_lambda_function" "producer" {
  function_name    = "auto_scaling_exercise_producer"
  filename         = data.archive_file.producer_code.output_path
  role             = aws_iam_role.producer.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.producer_code.output_base64sha256
  runtime          = "python3.8"

  environment {
    variables = {
      SQS_URL = aws_sqs_queue.task_queue.url
    }
  }
}

