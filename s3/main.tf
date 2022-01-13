provider "aws" {
  region  = "us-east-1"
  profile = "" //credencias aws-cli
}

resource "aws_s3_bucket" "my-test-bucket" {

  bucket = "my-test-bucket-test"
  acl    = "private"

  tags = {

    Name        = "my bucket"
    Environment = "Dev"
    Manageby    = "Terraform"
  }

}