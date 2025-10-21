terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket         = "terraform-state-lab6-serhii-2025"
    key            = "lab6/terraform.tfstate"
    region         = var.aws_region
    encrypt        = true
  }
}
