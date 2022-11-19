# AWS BUCKET S3 PROJECT (ATLANTIS WORKFLOW DEMO)

locals {
  entity      = "theautomationrules"
  environment = "testing"
  region      = "eu-central-1"
  vault_addr  = "vault"
  iteration   = "05"
  aws_account = "vault_nuc"
}

# ------------------------------------------------------------------------------
# PROVIDER VAULT

provider "vault" {
  skip_tls_verify = true
  address         = "http://${local.vault_addr}:8200"
}

# ------------------------------------------------------------------------------
# DATA

# SECRETS FROM CLOUD/KV SECRET ENGINE / VAULT

# AWS SUBSCRIPTION
data "vault_generic_secret" "aws_creds" {
  path = "cloud/aws/${local.entity}/${local.aws_account}"
}

# ------------------------------------------------------------------------------
# PROVIDER AWS

provider "aws" {
  region     = local.region
  access_key = data.vault_generic_secret.aws_creds.data["access_key"]
  secret_key = data.vault_generic_secret.aws_creds.data["secret_key"]
}

# ------------------------------------------------------------------------------
# RESOURCE

# Bucket S3
resource "aws_s3_bucket" "bucket" {
  #bucket = var.bucket_name # IMPORTANT! Conflict with bucket_prefix
  bucket_prefix = "s3-${local.entity}-${local.region}-" # IMPORTANT! Conflict with bucket

  # TAGs of Resources
  tags = {
    Name      = "${local.entity}-${local.region}-${local.environment}"
    Team      = "IAC"
    Creator   = "Terraform"
    Test      = "DEMO"
    Iteration = local.iteration
  }
}

resource "aws_s3_bucket_acl" "acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.bucket.bucket

  rule {}
}

resource "aws_s3_bucket_public_access_block" "bucket-acl" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

# ------------------------------------------------------------------------------
# OUTPUT

output "bucket_arn" {
  value = aws_s3_bucket.bucket.arn
}
output "bucket_name" {
  value = aws_s3_bucket.bucket.bucket
}