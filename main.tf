terraform {
  required_version = ">= 1.3.6, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.24.0"
    }
  }

  # store the terraform state in a bucket
  backend "s3" {

    # Change this to your bucket name 
    bucket = "nextflow-terraform"
    key    = "terraform.state"
    region = "us-east-2"
  }
}

locals {
  common_tags = {
    Name      = "nextflow"
    terraform = "True"
  }
}

provider "aws" {
  region = "us-east-2"
  default_tags {
    tags = local.common_tags
  }
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}


