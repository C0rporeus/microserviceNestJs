provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "nestjs-vpc"
  }
}

resource "aws_subnet" "private" {

  cidr_block        = "10.0.3.0/24"
  vpc_id            = aws_vpc.main.id
  availability_zone = "us-east-1a"
  tags = {
    Name = "nestjs-private-subnet-1"
  }
}

resource "aws_subnet" "private_2" {
  cidr_block        = "10.0.4.0/24"
  vpc_id            = aws_vpc.main.id
  availability_zone = "us-east-1b"
  tags = {
    Name = "nestjs-private-subnet-2"
  }
}

resource "aws_subnet" "public" {
  count = 2

  cidr_block = "10.0.${count.index + 1}.0/24"
  vpc_id     = aws_vpc.main.id

  tags = {
    Name = "nestjs-public-subnet-${count.index + 1}"
  }
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_execution_role.name
}

resource "aws_alb" "main" {
  name               = "nestjs-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http.id]
  subnets = [
    aws_subnet.private.id,
    aws_subnet.private_2.id
  ]
}

resource "aws_alb_target_group" "main" {
  name        = "nestjs-target-group"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
}

resource "aws_alb_listener" "main" {
  load_balancer_arn = aws_alb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.main.arn
    type             = "forward"
  }
}

/* resource "aws_launch_configuration" "main" {
  name_prefix                 = "nestjs-launch-config"
  image_id                    = data.aws_ami.nestjs_app.id
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.allow_http.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker
              sudo service docker start
              sudo docker run -p 3000:3000 303638556798.dkr.ecr.us-east-1.amazonaws.com/dev-ops-neoris:latest
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "main" {
  name_prefix          = "nestjs-asg"
  launch_configuration = aws_launch_configuration.main.id
  min_size             = 2
  max_size             = 2
  vpc_zone_identifier  = aws_subnet.public.*.id

  lifecycle {
    create_before_destroy = true
  }

  target_group_arns = [aws_alb_target_group.main.arn]
} */

data "aws_ami" "nestjs_app" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public_az1" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_az2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_ecs_cluster" "main" {
  name = "nestjs-cluster"
}

resource "aws_ecs_task_definition" "nestjs" {
  family                   = "nestjs"
  container_definitions    = file("./ecs_task_definition.json")
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
}

resource "aws_ecs_service" "nestjs" {
  name            = "nestjs-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.nestjs.arn
  desired_count   = 2

  launch_type = "FARGATE"

  network_configuration {
    subnets = [
      aws_subnet.private.id,
      aws_subnet.private_2.id,
    ]

    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.main.arn
    container_name   = "nestjs-container"
    container_port   = 3000
  }
}
