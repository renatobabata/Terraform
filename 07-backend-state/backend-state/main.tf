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

// S3 bucket -> 
// Locking (Dynamo DB) -> to avoid the file to be corrupted by other users. Only one user per time will be able to update the file.

resource "aws_s3_bucket" "enterprise_backend_state" {
  bucket = "dev-applications-backend-state-renato" //unique name in aws
  
  // lifecycle is used to prevent it to be destroyed
  lifecycle{
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.enterprise_backend_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.enterprise_backend_state.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" // Advanced Encryption Standard
    }
  }
}

resource "aws_dynamodb_table" "enterprise_backend_lock" {
    name = "dev_application_locks"
    billing_mode = "PAY_PER_REQUEST"

    hash_key = "LockID"

    attribute {
      name = "LockID"
      type = "S" 
    }
} 