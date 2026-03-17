terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # S3 Backend for storing terraform state
  backend "s3" {
    bucket         = "devops-cicd-terraform-state-gajanand"
    key            = "ec2/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "devops-cicd-terraform-lock-gajanand"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}