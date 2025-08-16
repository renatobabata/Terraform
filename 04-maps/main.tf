variable "users" {
    default = {
                renato:"BR", 
                seiji:"JP", 
                terraform:"ES"
              }
}

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

resource "aws_iam_user" "my_iam_user" {
  for_each = var.users
  name = each.key
  tags = {
    country: each.value
  }
}
