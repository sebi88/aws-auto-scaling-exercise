data "aws_availability_zones" "available" {}

data "aws_region" "current" {}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.6.20241031.0-kernel-6.1-arm64"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

data "archive_file" "producer_code" {
  type        = "zip"
  source_dir  = "producer/"
  output_path = "auto_scaling_exercise_producer_code.zip"
}
