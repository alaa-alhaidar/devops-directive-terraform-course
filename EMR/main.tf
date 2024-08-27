provider "aws" {
  region = "eu-north-1" # Specify your AWS region
}

# Define IAM roles for EMR
resource "aws_iam_role" "emr_service_role" {
  name = "EMR_DefaultRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "elasticmapreduce.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "emr_service_policy_attachment" {
  role       = aws_iam_role.emr_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole"
}
resource "aws_iam_role_policy_attachment" "emr_service_s3_full_access" {
  role       = aws_iam_role.emr_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Define IAM roles for EC2
resource "aws_iam_role" "emr_ec2_role" {
  name = "EMR_EC2_DefaultRole"

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

resource "aws_iam_role_policy_attachment" "emr_ec2_policy_attachment" {
  role       = aws_iam_role.emr_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role" # provided by AWS
}
resource "aws_iam_role_policy_attachment" "emr_ec2_s3_full_access" {
  role       = aws_iam_role.emr_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
# ... you can add more arn policies

resource "aws_iam_instance_profile" "emr_instance_profile" {
  name = "EMR_EC2_InstanceProfile"
  role = aws_iam_role.emr_ec2_role.name
}

# Define the EMR cluster
resource "aws_emr_cluster" "example" {
  name          = "example-emr-cluster"
  release_label = "emr-6.5.0"         # Specify the desired EMR version
  applications  = ["Hadoop", "Spark"] # Applications to install on the cluster
  log_uri       = "s3://alaa-bucket/" # S3 bucket for logging
  service_role  = aws_iam_role.emr_service_role.arn
  ec2_attributes {
    key_name = var.key_name # SSH key for accessing EC2 instances
    #subnet_id                   = "subnet-xxxxxxxx"  # Specify your subnet ID
    instance_profile = aws_iam_instance_profile.emr_instance_profile.arn # Instance profile for EC2 instances
  }

  master_instance_group {
    instance_type  = var.instance_type
    instance_count = 1
  }

  core_instance_group {
    instance_type  = var.instance_type
    instance_count = 1 # Number of core/machine nodes
  }

  # Define the step to run a JAR file from S3
  step {
    name              = "Spark Step"
    action_on_failure = "CONTINUE"
    hadoop_jar_step {
      jar = "command-runner.jar"
      args = [
        "spark-submit",
        "--deploy-mode", "cluster",
        "--class", "com.Join",                                # Replace with the fully qualified class name
        "s3://alaa-bucket/custom-jar-name_scala2.12-0.1.jar", # Path to your JAR file in S3
        var.output_path                                       # Path to output in S3
      ]
    }
  }

  tags = {
    Name = "example-emr-cluster"
  }
}



