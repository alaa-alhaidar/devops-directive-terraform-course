terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket         = "alaa-bucket"
    key            = "terraform.tfstate" # The path within the bucket where the state file will be stored
    region         = "eu-north-1"
    #dynamodb_table = "my_dynamo_table"
    encrypt        = true # Ensures the state file is encrypted
  }
}

provider "aws" { # Configures the AWS provider to operate in the eu-north-1 region
  region = "eu-north-1" 
}
resource "aws_security_group" "rds_sg" { # aws_security_group: Creates a security group for the RDS instance
  name        = "rds-postgres-public-sg"
  description = "Allow public access to PostgreSQL RDS"

  # incoming calls
  /*
  	Opens port 5432 (PostgreSQL default port) to all IPv4 (0.0.0.0/0) and IPv6 (::/0) addresses.
		Allows incoming connections to the database from any IP address.
  */
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]           # For IPv4
    ipv6_cidr_blocks = ["::/0"]                # For IPv6
  }
  /*
  Allows all outgoing connections (protocol = "-1" permits all protocols).
	Public Access Warning: Allowing access from 0.0.0.0/0 and ::/0 
  means the database is publicly accessible, which is a security risk unless properly managed.
  */
  # outgoing calls 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # all protocols
    cidr_blocks = ["0.0.0.0/0"] # all ip
    ipv6_cidr_blocks = ["::/0"]
  }
}


resource "aws_db_instance" "default" {
  allocated_storage    = 20
  storage_type         = "gp2" # General Purpose SSD
  engine               = "postgres"
  engine_version       = "14.13"
  instance_class       = "db.t3.micro"
  name                 = "test"
  username             = "alaa" # in authentication felds 
  password             = "alaa1234" # in authentication felds 
  publicly_accessible  = true
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id] # Associates the instance with the security group created earlier

  tags = {
    Name = "test"
  }
}
/*
RDS POSTGRES versions
12.15   12.16   12.17   12.18   12.19   12.20   12.21   12.22   13.15   13.16   13.17   13.18   14.12   14.13   14.14   14.15   15.7    15.8    15.9    15.10   16.3    16.4    16.5    16.6    17.1    17.2
*/

/*
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,       -- Auto-incrementing ID for each user
    username VARCHAR(50) UNIQUE NOT NULL,  -- Username, must be unique
    password VARCHAR(255) NOT NULL,        -- Password (should be hashed)
    email VARCHAR(100) UNIQUE NOT NULL,    -- Email, must be unique
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Timestamp of user creation
    last_login TIMESTAMP                    -- Timestamp of the last login
);

-- Insert 10 users into the users table
INSERT INTO users (username, password, email) VALUES
('user1', 'hashed_password1', 'user1@example.com'),
('user2', 'hashed_password2', 'user2@example.com'),
('user3', 'hashed_password3', 'user3@example.com'),
('user4', 'hashed_password4', 'user4@example.com'),
('user5', 'hashed_password5', 'user5@example.com'),
('user6', 'hashed_password6', 'user6@example.com'),
('user7', 'hashed_password7', 'user7@example.com'),
('user8', 'hashed_password8', 'user8@example.com'),
('user9', 'hashed_password9', 'user9@example.com'),
('user10', 'hashed_password10', 'user10@example.com');

*/