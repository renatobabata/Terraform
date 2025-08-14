terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.8"
    }
  }
}

variable "iam_user_name_prefix" {
  type    = string #any(default), number, bool, list, map, set, object, tuple
  default = "my_iam_user"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_user" "my_iam_user" {
  count = 2
  name  = "${var.iam_user_name_prefix}_${count.index}"
}

# 1 - plan -> before executing the command, we must test if the configuration is valid.
# 2 - execute -> if the plan is successfull, then we can execute it.

# STATE
# DESIRED - KNOWN - ACTUAL
