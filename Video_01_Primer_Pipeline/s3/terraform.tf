terraform {
  required_version = ">= 0.12"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.3.0"
    }
  }
  backend "s3" {
    shared_credentials_files = ["/home/atlantis/.aws/credentials"]
    profile                  = "testing"
  }
}