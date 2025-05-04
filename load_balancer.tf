# Application Load Balancer
resource "aws_lb" "ecs_task_alb" {
  name               = "ecs-task-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_task_alb_sg.id]
#   subnets            = [for subnet in aws_subnet.public : subnet.id]
  subnets            = [aws_subnet.ecs_task_public_1.id, aws_subnet.ecs_task_public_2.id]

  enable_deletion_protection = false

  tags = {
    Environment = "dev"
  }
}

# ALB Target Group
resource "aws_lb_target_group" "ecs_task_alb_target_group" {
  name     = "ecs-task-alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.ecs_task_vpc.id

  target_type = "ip"
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# ALB Listener
resource "aws_lb_listener" "ecs_task_alb_listener" {
  load_balancer_arn = aws_lb.ecs_task_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_task_alb_target_group.arn
  }
}