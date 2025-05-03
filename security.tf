# Application Load Balancer Security Group
resource "aws_security_group" "ecs_task_alb_sg" {
  name        = "ecs-task-alb-sg"
  description = "Allow HTTP access from the internet"
  vpc_id      = aws_vpc.ecs_task_vpc.id

  ingress {
    description = "Allow HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs_task_alb_sg"
  }
}

# ECS Task Security Group
resource "aws_security_group" "ecs_task_sg" {
  name        = "ecs-task-sg"
  description = "Allow HTTP traffic to ECS tasks"
  vpc_id      = aws_vpc.ecs_task_vpc.id

  ingress {
    description = "Allow HTTP from ALB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.ecs_task_alb_sg.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs_task_sg"
  }
}
