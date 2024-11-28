provider "aws" {
  region = "us-east-1"  # Change the region as needed
}

# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "main-igw"
  }
}

# Public Subnets (Frontend)
resource "aws_subnet" "frontend_subnet_1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "frontend-subnet-1"
  }
}

resource "aws_subnet" "frontend_subnet_2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "frontend-subnet-2"
  }
}

# Private Subnets (Database)
resource "aws_subnet" "backend_subnet_1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "database-subnet-1"
  }
}

resource "aws_subnet" "backend_subnet_2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "database-subnet-2"
  }
}

resource "aws_subnet" "database_subnet_1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-east-1c"
  tags = {
    Name = "database-subnet-3"
  }
}

resource "aws_subnet" "database_subnet_2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "us-east-1d"
  tags = {
    Name = "database-subnet-4"
  }
}

# ALB for Frontend
resource "aws_lb" "frontend_alb" {
  name               = "frontend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups   = [aws_security_group.frontend_sg.id]
  subnets            = [aws_subnet.frontend_subnet_1.id, aws_subnet.frontend_subnet_2.id]
  enable_deletion_protection = false
  tags = {
    Name = "frontend-alb"
  }
}

# ALB for Backend
resource "aws_lb" "backend_alb" {
  name               = "backend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups   = [aws_security_group.backend_sg.id]
  subnets            = [aws_subnet.frontend_subnet_1.id, aws_subnet.frontend_subnet_2.id]
  enable_deletion_protection = false
  tags = {
    Name = "backend-alb"
  }
}

# S3 Bucket
resource "aws_s3_bucket" "main_bucket" {
  bucket = "my-unique-bucket-name"
  acl    = "private"

  tags = {
    Name = "main-s3-bucket"
  }
}

# Security Group for Frontend
resource "aws_security_group" "frontend_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = {
    Name = "frontend-sg"
  }
}

# Security Group for Backend
resource "aws_security_group" "backend_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = {
    Name = "backend-sg"
  }
}

# Security Group for RDS Database
resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = {
    Name = "rds-sg"
  }
}
