aws_region                    = "us-east-2"
vpc_cidr_block                = "10.0.0.0/16"
subnet_count                  = 2
ecs_cluster_name              = "my-ecs-cluster"
ecs_task_execution_role_name  = "ecs-task-execution-role"
ecs_task_family               = "my-ecs-task"
ecs_task_cpu                  = "256"
ecs_task_memory               = "512"
container_image               = "nginx:latest"
load_balancer_name            = "my-ecs-lb"
lb_listener_port              = 80
target_group_name             = "ecs-target-group"
ecs_security_group_name       = "ecs-service-sg"
lb_security_group_name        = "lb-sg"
