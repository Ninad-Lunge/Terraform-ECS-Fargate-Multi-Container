# VPC
resource "aws_vpc" "ecs_task_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "ecs_task_vpc"
  }
}

# Public Subnet 1
resource "aws_subnet" "ecs_task_public_1" {
  vpc_id = aws_vpc.ecs_task_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "ecs_task_public_subnet_1"
  }
}

# Public Subnet 2
resource "aws_subnet" "ecs_task_public_2" {
  vpc_id = aws_vpc.ecs_task_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "ecs_task_public_subnet_2"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "ecs_task_igw" {
  vpc_id = aws_vpc.ecs_task_vpc.id

  tags = {
    Name = "ecs_task_igw"
  }
}

# Public Route Table
resource "aws_route_table" "ecs_task_rt_public" {
  vpc_id = aws_vpc.ecs_task_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecs_task_igw.id
  }
}

# Public Route Table Associations
resource "aws_route_table_association" "ecs_task_rt_assoc_1" {
  subnet_id      = aws_subnet.ecs_task_public_1.id
  route_table_id = aws_route_table.ecs_task_rt_public.id
}

resource "aws_route_table_association" "ecs_task_rt_assoc_2" {
  subnet_id      = aws_subnet.ecs_task_public_2.id
  route_table_id = aws_route_table.ecs_task_rt_public.id
}