# TODO: Designate a cloud provider, region, and credentials

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.10.0"
    }
  }
}

locals {
  aws_region = "us-east-1"
  ami = "ami-053b0d53c279acc90"
  t2_instance = "t2.micro"
  m4_instance = "m4.large"
  t2_name = "Udacity T2"
  m4_name = "Udacity M4"
}

provider "aws" {
  region = local.aws_region
}

data "aws_vpc" "default_vpc" {
  default = true  
}

data "aws_subnet" "public_subnet" {
  vpc_id = data.aws_vpc.default_vpc.id
  availability_zone = "us-east-1a"
}


# TODO: provision 4 AWS t2.micro EC2 instances named Udacity T2

resource "aws_instance" "t2_instances" {
  ami = local.ami
  instance_type = local.t2_instance
  subnet_id = data.aws_subnet.public_subnet.id
  tags = {
    Name = local.t2_name
  }
  count = 4
}


# TODO: provision 2 m4.large EC2 instances named Udacity M4

# resource "aws_instance" "m4_instances" {
#   ami = local.ami
#   instance_type = local.m4_instance
#   subnet_id = data.aws_subnet.public_subnet.id
#   tags = {
#     Name = local.m4_name
#   }
#   count = 2
# }

