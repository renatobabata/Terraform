# resource "provider + resource type" "name of the object in Terraform" {}
resource "aws_s3_bucket" "my_s3_bucket"{
    bucket = "my-s3-bucket-renato-terraform-02"
}

resource "aws_iam_user" "my_iam_user" {
name = "${terraform.workspace}_my_iam_user_updated"
}

resource "aws_s3_bucket_versioning" "versioning_example" {
    bucket = aws_s3_bucket.my_s3_bucket.id
    versioning_configuration {
        status = "Enabled"
    }
} 