
locals {
  bucket_name = lower("${var.project}-${var.env}-${var.region}-tfstate")
  table_name  = lower("${var.project}-${var.env}-tf-locks")
  common_tags = merge(var.tags, {
    Project     = var.project
    Environment = var.env
    ManagedBy   = "Terraform"
  })
}

provider "aws" {
  region = var.region
}

# S3 bucket for Terraform state
resource "aws_s3_bucket" "tfstate" {
  bucket        = local.bucket_name
  force_destroy = var.s3_force_destroy

  tags = local.common_tags
}

# Block public access as a defense-in-depth
resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Versioning for state (enables rollback/recovery)
resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Server-side encryption: KMS if provided, else SSE-S3
resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_arn == null ? "AES256" : "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
  }
}

# Optional lifecycle: manage non-current versions
resource "aws_s3_bucket_lifecycle_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    id     = "manage-noncurrent-versions"
    status = "Enabled"

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = var.lifecycle_days
    }
  }
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "tf_locks" {
  name         = local.table_name
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }

  # Optional TTL pattern (disabled by default)
  # ttl {
  #   attribute_name = "ExpireAt"
  #   enabled        = true
  # }

  tags = local.common_tags
}

output "bucket_name" {
  value       = aws_s3_bucket.tfstate.bucket
  description = "S3 bucket name for Terraform state."
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.tf_locks.name
  description = "DynamoDB table name for Terraform state locking."
}

