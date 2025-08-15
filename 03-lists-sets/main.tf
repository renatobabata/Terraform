variable "name" {
    default = ["renato", "seiji", "terraform"]
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
  #count = length(var.name)
  #name  = var.name[count.index]
  for_each = toset(var.name)
  name = each.value
}
#https://developer.hashicorp.com/terraform/language/functions

# 1 - plan -> before executing the command, we must test if the configuration is valid.
# 2 - execute -> if the plan is successfull, then we can execute it.

# STATE
# DESIRED - KNOWN - ACTUAL
