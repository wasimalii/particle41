# NOTE: To execute this Terraform script, you need to to export AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY or any othet method to authenticate to aws.

#export AWS_ACCESS_KEY_ID=ghdsbhdbsdbhbs
#export AWS_SECRET_ACCESS_KEY=bhjdsvchsjsvdggv


provider "aws" {
  region = var.aws_region
}

# Creating VPC 
resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "MyVPC"
  }
}

# Creating Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "MyInternetGateway"
  }
}


# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
    Name = "PublicRouteTable"
  }
}

# sourcing Data of Availability Zones for later use in our resources.
data "aws_availability_zones" "available" {
  state = "available"
}


# create 2 Public Subnets in loop using count 
resource "aws_subnet" "public_subnets" {
  count                   = var.subnet_count
  vpc_id                  = aws_vpc.my_vpc.id  # refering id of ou vpc 
  cidr_block              = "10.0.${count.index}.0/24"  # start index 0 goes to 1
  availability_zone       = element(data.aws_availability_zones.available.names, count.index) # uses the count.index to select an AZ from the available zones in the AWS region.
  map_public_ip_on_launch = true  # the ec2 instance in this subnet will get public ip by default
  tags = {
    Name = "PublicSubnet-${count.index + 1}" 
  }
}

# associate route table with public subnet
resource "aws_route_table_association" "public_rt_association" {
  count          = var.subnet_count
  subnet_id      = aws_subnet.public_subnets[count.index].id 
  route_table_id = aws_route_table.public_rt.id
}

# Elastic IP for NAT gateway
resource "aws_eip" "nat_eip" {
  vpc = true
  tags = {
    Name = "NAT-EIP"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets[0].id
  tags = {
    Name = "NAT-Gateway"
  }
}

# Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = {
    Name = "PrivateRouteTable"
  }
}

# create 2 private Subnets in loop uses count 
resource "aws_subnet" "private_subnets" {
  count                   = var.subnet_count
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.${count.index + 2}.0/24"
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = false
  tags = {
    Name = "PrivateSubnet-${count.index + 1}"
  }
}

# associate route table with private subnet
resource "aws_route_table_association" "private_rt_association" {
  count          = var.subnet_count
  subnet_id      = aws_subnet.private_subnets[count.index].id # uses count it will take the id of subnets and associate the route table 
  route_table_id = aws_route_table.private_rt.id
}


## Data for Availability Zones
#data "aws_availability_zones" "available" {
#  state = "available"
#}


# Creating ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.ecs_cluster_name
}

# Creating IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = var.ecs_task_execution_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

# # associate IAM role with task
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "ecs_task" {
  family                   = var.ecs_task_family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions    = jsonencode([
    {
      name        = "myapp-nginx-container"
      image       = var.container_image
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}


# ECS Service
resource "aws_ecs_service" "ecs_service" {
  name            = "my-ecs-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_tg.arn
    container_name   = "myapp-nginx-container"
    container_port   = 80
  }

  network_configuration {
    subnets         = aws_subnet.private_subnets.*.id  # This is dynamically referenced
    security_groups = [aws_security_group.ecs_sg.id]
  }
}


# Security group for ECS task
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-service-sg"
  description = "Allow traffic for ecs service"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ALB in Public Subnet
resource "aws_lb" "ecs_lb" {
  name               = var.load_balancer_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = aws_subnet.public_subnets.*.id
}

# ALB Listener
resource "aws_lb_listener" "ecs_lb_listener" {
  load_balancer_arn = aws_lb.ecs_lb.arn
  port              = var.lb_listener_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}

# Target group for ECS tasks
resource "aws_lb_target_group" "ecs_tg" {
  name        = var.target_group_name
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.my_vpc.id
  target_type = "ip" # set this using in ECS

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

# Security group for ALB
resource "aws_security_group" "lb_sg" {
  name        = "lb-sg"
  description = "Allow http traffic for ALB"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
