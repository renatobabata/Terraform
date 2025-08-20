terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.8"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

//HTTP Server -> SG
//Security Group for 80 TCP, 22 TCP, CIDR (to specify the range of IP) ["0.0.0.0/0"]
//https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "http_server_sg" {
  name   = "http_server_sg"
  vpc_id = "vpc-0fdc2036e884187e5"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // egresss allows traffic to anywhere. This is the standard Terraform configuration
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "http_server_sg"
  }
}

//Create an EC2 instance - http server

resource "aws_instance" "http_server" {
  ami                    = "ami-0de716d6197524dd9"                // amazon machine image
  key_name               = "default-ec2"                          //key pair 
  instance_type          = "t2.micro"                             //hardware
  vpc_security_group_ids = [aws_security_group.http_server_sg.id] //security_group
  subnet_id              = "subnet-0addca6a1ebc33a46"             //what subnet this should be created in
}