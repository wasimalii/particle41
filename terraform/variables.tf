variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_count" {
  description = "number of subnets"
  default     = 2
}

variable "ecs_cluster_name" {
  description = "ECS cluster name"
  default     = "my-ecs-cluster"
}

variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  default     = "ecs-task-execution-role"
}

variable "ecs_task_family" {
  description = "ECS task family"
  default     = "my-ecs-task"
}

variable "ecs_task_cpu" {
  description = "ECS task CPU"
  default     = "256"
}

variable "ecs_task_memory" {
  description = "ECS task Memory"
  default     = "512"
}

variable "container_image" {
  description = "Container image for ECS task"
  default     = "nginx:latest"
}

variable "load_balancer_name" {
  description = "ALB name"
  default     = "my-ecs-lb"
}

variable "lb_listener_port" {
  description = "Listener port for ALB"
  default     = 80
}

variable "target_group_name" {
  description = "Target group name"
  default     = "ecs-target-group"
}


variable "ecs_security_group_name" {
  description = "Security Group name for ECS task"
  default     = "ecs-service-sg"
}

variable "lb_security_group_name" {
  description = "Security Group name for LB"
  default     = "lb-sg"
}
