resource "aws_iam_policy" "consumer" {
  name = "auto_scaling_exercise_consumer"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage"]
        Effect   = "Allow"
        Resource = aws_sqs_queue.task_queue.arn
      },
    ]
  })
}

resource "aws_iam_role" "consumer" {
  name                = "auto_scaling_exercise_consumer"
  managed_policy_arns = [aws_iam_policy.consumer.arn, "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "consumer" {
  name = "auto_scaling_exercise_consumer"
  role = aws_iam_role.consumer.name
}

resource "aws_security_group" "consumer" {
  name   = "auto_scaling_exercise_consumer"
  vpc_id = aws_vpc.consumer.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "auto_scaling_exercise"
  }
}

resource "aws_launch_template" "consumer" {
  name = "auto_scaling_exercise_consumer"

  disable_api_stop        = true
  disable_api_termination = true

  iam_instance_profile {
    arn = aws_iam_instance_profile.consumer.arn
  }

  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = "t4g.nano"

  monitoring {
    enabled = false
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.consumer.id]
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 8
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  user_data = base64encode(templatefile("consumer/user_data.tftpl", {
    sqs_url = aws_sqs_queue.task_queue.url
  }))
}

resource "aws_autoscaling_group" "consumer" {
  name              = "auto_scaling_exercise_consumer"
  min_size          = 0
  max_size          = 10
  desired_capacity  = 0
  health_check_type = "EC2"

  enabled_metrics = ["GroupInServiceInstances"]

  launch_template {
    id      = aws_launch_template.consumer.id
    version = "$Latest"
  }
  vpc_zone_identifier = [aws_subnet.consumer_private.id]

  tag {
    key                 = "Name"
    value               = "auto_scaling_exercise"
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

