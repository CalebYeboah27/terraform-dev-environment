terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }

    # docker = {
    #   source  = "kreuzwerker/docker"
    #   version = "3.0.2"
    # }
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
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.web_subnet
  availability_zone = var.subnet_zone

  tags = {
    Name = "Web Subnet"
  }
}


resource "aws_internet_gateway" "my_web_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.main_vpc_name} IGW"
  }
}

resource "aws_default_route_table" "main_vpc_default_rt" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_web_igw.id
  }

  tags = {
    Name = "my-default-rt"
  }
}

resource "aws_default_security_group" "default_sec_group" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # any protocol
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "Default Security Group"
  }
}

# Create a new Key Pair
resource "aws_key_pair" "terraform_ssh_pair" {
  key_name = "terraform_rsa" 
  public_key = file(var.ssh_public_key)
}


data "aws_ami" "latest_amazon_linux2" {
  owners = [ "amazon" ]
  most_recent = true
  filter {
    name = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"] 
  }

  filter {
    name = "architecture"
    values = [ "x86_64" ]
  }

}

resource "aws_instance" "web-server" {
  ami                         = data.aws_ami.latest_amazon_linux2.id 
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.web.id
  vpc_security_group_ids      = [aws_default_security_group.default_sec_group.id]
  associate_public_ip_address = true
  user_data = file("script.sh")
  key_name                    = aws_key_pair.terraform_ssh_pair.key_name
  tags = {
    "Name" : "My Public Web Server"
  }
}

