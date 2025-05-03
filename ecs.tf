# ECS Cluster
resource "aws_ecs_cluster" "ecs_task_cluster" {
  name = "aspnet-core-fargate-cluster"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "ecs_task_task_definition" {
  family                   = "ecs_task_task_definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  container_definitions = jsonencode([
    {
      name      = "mymvcweb"
      image     = "972251037418.dkr.ecr.us-east-1.amazonaws.com/mymvcweb:latest"
      cpu       = 0
      memory    = 1024
      essential = true
      protocol = "tcp"
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
    },
    {
      name      = "reverse-proxy"
      image     = "972251037418.dkr.ecr.us-east-1.amazonaws.com/reverseproxy:latest"
      cpu       = 0
      memory    = 1024
      essential = true
      protocol = "tcp"
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
  task_role_arn = "arn:aws:iam::972251037418:role/ecsTaskExecutionRole"
  execution_role_arn = "arn:aws:iam::972251037418:role/ecsTaskExecutionRole"
}

# ECS Service
resource "aws_ecs_service" "ecs_task_service" {
  name            = "ecs_task_service"
  cluster         = aws_ecs_cluster.ecs_task_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_task_definition.id
  desired_count   = 2
  launch_type = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_task_alb_target_group.arn
    container_name   = "reverse-proxy"
    container_port   = 80
  }

  network_configuration {
    subnets         = [aws_subnet.ecs_task_public_1.id, aws_subnet.ecs_task_public_2.id]
    security_groups = [aws_security_group.ecs_task_sg.id]
    assign_public_ip = true
  }
  
  depends_on = [ aws_lb_listener.front_end ]
}