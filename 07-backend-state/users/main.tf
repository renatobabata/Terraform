terraform {
    backend "s3" { 
      bucket = "dev-applications-backend-state-renato"
      key = "dev/07-backend-state/users/backend-state"
      region = "us-east-1"
      dynamodb_table = "dev_application_locks"
      encrypt = true 
    }
}

provider "aws" { 
    region = "us-east-1"
}

