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

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc
resource "aws_default_vpc" "default" {

}

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

resource "aws_security_group" "elb_sg" {
  name   = "elb_sg"
  vpc_id = aws_default_vpc.default.id
  ingress {
    from_port   = 80
    to_port     = 80
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
}


#resource for load balancer
resource "aws_elb" "elb" {
  name            = "elb"
  subnets         = data.aws_subnets.default_subnets.ids
  security_groups = [aws_security_group.elb_sg.id]
  instances       = values(aws_instance.http_server).*.id

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

#Create an EC2 instance - http server
resource "aws_instance" "http_server" {
  #ami                    = "ami-0de716d6197524dd9"                # amazon machine image
  ami                    = data.aws_ami.aws_linux_2_latest.id
  key_name               = "default-ec2"                          # key pair 
  instance_type          = "t2.micro"                             # hardware
  vpc_security_group_ids = [aws_security_group.http_server_sg.id] # security_group

  for_each  = toset(data.aws_subnets.default_subnets.ids)
  subnet_id = each.value

  tags = {
    name : "http_servers_${each.value}"
  }

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