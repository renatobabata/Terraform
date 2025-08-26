variable "environment" {
  default = "default"
}

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


