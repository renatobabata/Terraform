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

# resource "provider + resource type" "name of the object in Terraform" {}
resource "aws_s3_bucket" "my_s3_bucket"{
    bucket = "my-s3-bucket-renato-terraform-02"
}

resource "aws_iam_user" "my_iam_user" {
    name = "my_iam_user_updated"
}

resource "aws_s3_bucket_versioning" "versioning_example" {
    bucket = aws_s3_bucket.my_s3_bucket.id
    versioning_configuration {
        status = "Enabled"
    }
} 


# STATE
# DESIRED - KNOWN - ACTUAL

output "my_s3_bucket_versioning" {
    value = aws_s3_bucket_versioning.versioning_example.versioning_configuration[0].status
}

output "my_s3_bucket_complete_details" {
    value = aws_s3_bucket.my_s3_bucket
}

output "my_iam_user_complete_details" {
    value = aws_iam_user.my_iam_user
}