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
    encrypt        = true
  }
}

provider "aws" {
  profile = "alaa-aws"
  region  = "eu-north-1"
}

# IAM Role for DMS to Access S3
resource "aws_iam_role" "dms_s3_role" {
  name = "dms-s3-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "dms.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach Policy for S3 Access
resource "aws_iam_policy" "dms_s3_policy" {
  name = "dms-s3-access-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::alaa-bucket",
          "arn:aws:s3:::alaa-bucket/*"
        ]
      }
    ]
  })
}

# Attach Policy to IAM Role
resource "aws_iam_role_policy_attachment" "attach_dms_s3_policy" {
  role       = aws_iam_role.dms_s3_role.name
  policy_arn = aws_iam_policy.dms_s3_policy.arn
}

# Create the S3 Endpoint for DMS
resource "aws_dms_endpoint" "source_s3" {
  endpoint_id         = "source-s3-endpoint"
  endpoint_type       = "source"
  engine_name         = "s3"
  service_access_role = aws_iam_role.dms_s3_role.arn  # Correct ARN reference for the IAM role

  extra_connection_attributes = "dataFormat=sql;bucketFolder=/;bucketName=alaa-bucket;fileName=yourdatabase_backup.sql"

  s3_settings {
    bucket_name     = "alaa-bucket"
    bucket_folder   = "/"    # Root folder in the bucket (if needed)
    compression_type = "NONE"
  }
}

# Create the RDS Endpoint (Target)
resource "aws_dms_endpoint" "target_rds" {
  endpoint_id   = "target-rds-endpoint"
  endpoint_type = "target"
  engine_name   = "postgres"

  username      = "alaa"                               # Replace with your RDS username
  password      = "alaa1234"                           # Replace with your RDS password
  server_name   = "test.cfvherirgxds.eu-north-1.rds.amazonaws.com" # Replace with your RDS endpoint
  port          = 5432                                 # Corrected port for PostgreSQL
  database_name = "test"                               # Target database name
}

# Create a DMS Replication Instance
resource "aws_dms_replication_instance" "replication_instance" {
  replication_instance_id   = "dms-replication-instance"
  replication_instance_class = "dms.t3.micro"
  allocated_storage         = 50

  publicly_accessible = true
  tags = {
    Name = "MyDMSReplicationInstance"
  }
}
# Create the DMS Task to Migrate Data
resource "aws_dms_replication_task" "replication_task" {
  replication_task_id          = "migrate-sql-dump-to-rds"
  source_endpoint_arn          = aws_dms_endpoint.source_s3.endpoint_arn
  target_endpoint_arn          = aws_dms_endpoint.target_rds.endpoint_arn
  migration_type               = "full-load"
  replication_instance_arn     = aws_dms_replication_instance.replication_instance.replication_instance_arn

  table_mappings = jsonencode({
    rules = [
      {
        rule-type = "selection",
        rule-id   = "1",
        rule-name = "1",
        enabled   = true,
        filter-conditions = [],
        rule-action = "include",
        object-locator = {
          schema-name = "%"
          table-name  = "%"
        }
      }
    ]
  })
}