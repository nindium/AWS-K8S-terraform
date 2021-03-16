provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    region         = "us-east-1"
    bucket         = "nindium-store"
    key            = "K8S/terraform.tfstate"
    dynamodb_table = "terraform-k8s"
  }
}

