terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 6.8"
      }
    }
}

provider "aws" { 
    region = "us-east-1"
}


# 1 - plan -> before executing the command, we must test if the configuration is valid.
# 2 - execute -> if the plan is successfull, then we can execute it.

# STATE
# DESIRED - KNOWN - ACTUAL
