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
  cidr_block = var.vpc_cidr_block

  tags = {
    "Name" = "Production ${var.main_vpc_name}"
  }
}

# Create a subnet
resource "aws_subnet" "web" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.web_subnet
  availability_zone = var.subnet_zone

  tags = {
    Name = "Web Subnet"
  }
}