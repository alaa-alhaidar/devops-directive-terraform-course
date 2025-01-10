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
    dynamodb_table = "my_dynamo_table"
    encrypt        = true
  }
}
provider "aws" {
  region = "eu-north-1"
}

data "aws_vpc" "default_vpc" {
  default = true
}

# Query subnets in the default VPC
data "aws_subnet_ids" "default_subnet" {
  vpc_id = data.aws_vpc.default_vpc.id
}

# IAM Role for Terraform
resource "aws_iam_role" "terraform_role" {
  name = "TerraformExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_full_access" {
  role       = aws_iam_role.terraform_role.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "iam_read_only" {
  role       = aws_iam_role.terraform_role.name
  policy_arn  = "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
}

# S3 Bucket for Terraform State
resource "aws_s3_bucket" "example_bucket" {
  bucket_prefix = "example-bucket-"
  force_destroy = true
}

# DynamoDB Table for State Locking
resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}


