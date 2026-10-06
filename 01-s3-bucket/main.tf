terraform {
  backend "s3" {
    bucket         = "dwight-terraform-state-2026-unique"
    key            = "01-s3-bucket/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }

  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"

  assume_role {
    role_arn = "arn:aws:iam::<ACCOUNT HOLDER>:role/TerraformDeploymentRole"
  }
}

resource "aws_s3_bucket" "secure_bucket" {
  bucket = "dwight-secure-tf-bucket-123456"
}

resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.secure_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}