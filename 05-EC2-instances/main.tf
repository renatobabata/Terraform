terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.8"
    }
  }
}

variable "aws_key_pair" {
  default = "~/aws/aws_keys/default-ec2.pem"
}

provider "aws" {
  region = "us-east-1"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc
resource "aws_default_vpc" "default" {

}

# data provider subnets
data "aws_subnets" "default_subnets" {
  filter {
    name   = "vpc-id"
    values = [aws_default_vpc.default.id]
  }
}

# data provider AMI 
data "aws_ami" "aws_linux_2_latest" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*"]   
  }
}

data "aws_ami_ids" "aws_linux_2_latest_ids" {
  owners = ["amazon"]
}

#filter {
#name = "name"
#values = ["amzn2-ami-kernel-5.10-hvm*"]
#}
 
#filter {
#name = "architecture"
#values = ["x86_64"]
#}


//HTTP Server -> SG
//Security Group for 80 TCP, 22 TCP, CIDR (to specify the range of IP) ["0.0.0.0/0"]
//https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "http_server_sg" {
  name = "http_server_sg"
  #vpc_id = "vpc-0fdc2036e884187e5"
  vpc_id = aws_default_vpc.default.id
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

#Create an EC2 instance - http server
resource "aws_instance" "http_server" {
  #ami                    = "ami-0de716d6197524dd9"                # amazon machine image
  ami                    = data.aws_ami.aws_linux_2_latest.id 
  key_name               = "default-ec2"                          # key pair 
  instance_type          = "t2.micro"                             # hardware
  vpc_security_group_ids = [aws_security_group.http_server_sg.id] # security_group
  #subnet_id              = "subnet-0addca6a1ebc33a46"             # what subnet this should be created in
  subnet_id              = tolist(data.aws_subnets.default_subnets.ids)[0]

  # to connect to EC2 instance
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.aws_key_pair)
  }

  # to execute commands
  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd -y",                                              # install httpd 
      "sudo service httpd start",                                               # start the server up
      "echo Hello World ${self.public_dns} | sudo tee /var/www/html/index.html" # copy a file

    ]
  }
}