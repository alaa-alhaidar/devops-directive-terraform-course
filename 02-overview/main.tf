provider "aws" {
  region = "eu-north-1"
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "example" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  tags = {
    Name = "ExampleInstance"
  }
}
terraform {
  backend "s3" {
    bucket         = "alaa-bucket"
    key            = "terraform/state.tfstate"
    region         = "eu-north-1"
    encrypt        = true
    dynamodb_table = "my_dynamo_table"  # Optional for state locking
  }
}




/*
  terraform init
  terraform plan
  terraform apply
  terraform destroy
  terraform state
  //  list              List resources in the state
    mv                  Move an item in the state
    pull                Pull current state and output to stdout
    push                Update remote state from a local state file
    replace-provider    Replace provider in the state
    rm                  Remove instances from the state
    show                Show a resource in the state
  terraform output
  terraform import

  aws ec2 describe-images --owners self amazon --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*" --region eu-north-1
*/