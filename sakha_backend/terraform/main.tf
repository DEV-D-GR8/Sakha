terraform {
  required_version = ">= 1.0"

  backend "s3" {
    bucket = var.terraform_state_bucket
    key    = "terraform/state.tfstate"
    region = var.aws_region
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
