terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-2"
}

variable "logs_bucket_name" {
  type        = string
  description = "Unique S3 bucket name for central logs"
}

variable "kms_key_arn" {
  type        = string
  description = "KMS key ARN used to encrypt logs"
}

resource "aws_s3_bucket" "logs" {
  bucket                = var.logs_bucket_name
  object_lock_enabled   = true

  tags = { Purpose = "central-logs", Project = "AWS-HealthLake" }
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_object_lock_configuration" "this" {
  bucket = aws_s3_bucket.logs.id
  rule {
    default_retention {
      mode = "COMPLIANCE"
      days = 90
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Organization-wide CloudTrail (single account example)
resource "aws_cloudtrail" "org" {
  enable_log_file_validation     = true
  name                          = "org-trail"
  s3_bucket_name                = aws_s3_bucket.logs.bucket
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true
  kms_key_id                    = var.kms_key_arn
}

output "logs_bucket" { value = aws_s3_bucket.logs.bucket }