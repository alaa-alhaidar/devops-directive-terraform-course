terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket         = "alaa-bucket"
    key            = "terraform.tfstate"
    region         = "eu-north-1"
    #dynamodb_table = "my_dynamo_table"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-north-1"
}
# A security group in AWS is a virtual firewall that controls inbound and outbound traffic to and from your AWS resources.
resource "aws_security_group" "rds_sg" { 
  name        = "rds-public-sg"
  description = "Allow public access to RDS"

  ingress {
    from_port   = 3306
    to_port     = 3306
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

resource "aws_db_instance" "default" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  name                 = "mydatabase"
  username             = "admin"
  password             = "password123"
  parameter_group_name = "default.mysql8.0"
  publicly_accessible  = true
  skip_final_snapshot  = true

  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  tags = {
    Name = "MyRDSInstance"
  }
}

output "rds_endpoint" {
  value = aws_db_instance.default.endpoint
}
