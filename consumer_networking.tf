resource "aws_vpc" "consumer" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "auto_scaling_exercise"
  }
}

resource "aws_subnet" "consumer_public" {
  vpc_id            = aws_vpc.consumer.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "auto_scaling_exercise_public"
  }
}

resource "aws_internet_gateway" "consumer_public" {
  vpc_id = aws_vpc.consumer.id

  tags = {
    Name = "auto_scaling_exercise"
  }
}

resource "aws_route_table" "consumer_public" {
  vpc_id = aws_vpc.consumer.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.consumer_public.id
  }
}

resource "aws_route_table_association" "consumer_public" {
  subnet_id      = aws_subnet.consumer_public.id
  route_table_id = aws_route_table.consumer_public.id
}

resource "aws_eip" "nat_gateway" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.consumer_public.id
  tags = {
    Name = "auto_scaling_exercise"
  }
}

resource "aws_subnet" "consumer_private" {
  vpc_id            = aws_vpc.consumer.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "auto_scaling_exercise_private"
  }
}

resource "aws_route_table" "consumer_private" {
  vpc_id = aws_vpc.consumer.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

resource "aws_route_table_association" "consumer_private" {
  subnet_id      = aws_subnet.consumer_private.id
  route_table_id = aws_route_table.consumer_private.id
}
