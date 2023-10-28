terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"
}


resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    "Name" = "Main VPC"
  }
}

# Create a subnet
resource "aws_subnet" "web" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.10.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "Web Subnet"
  }
}