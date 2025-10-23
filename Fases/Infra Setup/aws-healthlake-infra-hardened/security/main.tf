terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

variable "kms_alias" { type = string default = "alias/healthlake-kms" }
variable "enable_security_hub" { type = bool default = true }
variable "enable_guardduty" { type = bool default = true }

provider "aws" {
  region = var.region
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-2"
}

# KMS key for general encryption
resource "aws_kms_key" "data" {
  description         = "KMS CMK for HealthLake and logs"
  enable_key_rotation = true
  deletion_window_in_days = 30
  tags = { Project = "AWS-HealthLake" }
}

resource "aws_kms_alias" "data_alias" {
  name          = var.kms_alias
  target_key_id = aws_kms_key.data.key_id
}

# Security Hub
resource "aws_securityhub_account" "this" {
  count = var.enable_security_hub ? 1 : 0
}

resource "aws_securityhub_standards_subscription" "fsbp" {
  count          = var.enable_security_hub ? 1 : 0
  standards_arn  = "arn:aws:securityhub:::ruleset/aws-foundational-security-best-practices/v/1.0.0"
  depends_on     = [aws_securityhub_account.this]
}

resource "aws_securityhub_standards_subscription" "cis" {
  count          = var.enable_security_hub ? 1 : 0
  standards_arn  = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
  depends_on     = [aws_securityhub_account.this]
}

# GuardDuty
resource "aws_guardduty_detector" "this" {
  count  = var.enable_guardduty ? 1 : 0
  enable = true
}

# Account Password policy (baseline)
resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 14
  require_lowercase_characters   = true
  require_uppercase_characters   = true
  require_numbers                = true
  require_symbols                = true
  allow_users_to_change_password = true
  max_password_age               = 90
  password_reuse_prevention      = 24
}

output "kms_key_arn" { value = aws_kms_key.data.arn }

# -------------------------
# AWS Config + Managed Rules (GDPR-aligned baseline)
# -------------------------

variable "config_logs_bucket_name" {
  type        = string
  description = "S3 bucket name for AWS Config delivery (use central logs bucket)"
  default     = null
}

# IAM role for AWS Config
resource "aws_iam_role" "config_role" {
  name               = "aws-config-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "config.amazonaws.com" },
      Action   = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "config_policy" {
  name = "aws-config-policy"
  role = aws_iam_role.config_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ],
        Resource = [
          "arn:aws:s3:::${var.config_logs_bucket_name}",
          "arn:aws:s3:::${var.config_logs_bucket_name}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "config:Put*",
          "config:Get*",
          "config:Batch*",
          "config:Describe*",
          "ec2:Describe*",
          "iam:List*",
          "iam:Get*",
          "kms:ListKeys",
          "kms:ListAliases",
          "kms:DescribeKey",
          "s3:ListAllMyBuckets",
          "s3:GetBucketLocation",
          "lambda:List*",
          "lambda:Get*",
          "cloudtrail:DescribeTrails",
          "cloudtrail:GetTrailStatus"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_config_configuration_recorder" "recorder" {
  name     = "default"
  role_arn = aws_iam_role.config_role.arn
  recording_group {
    all_supported = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "channel" {
  name           = "default"
  s3_bucket_name = var.config_logs_bucket_name
  depends_on     = [aws_config_configuration_recorder.recorder]
}

resource "aws_config_configuration_recorder_status" "status" {
  name       = aws_config_configuration_recorder.recorder.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.channel]
}

# Managed Rules (selection mapped to common GDPR controls)
locals {
  managed_rules = [
    "CLOUD_TRAIL_ENABLED",
    "CLOUD_TRAIL_LOG_FILE_VALIDATION_ENABLED",
    "CLOUDWATCH_LOG_GROUP_ENCRYPTED",
    "IAM_PASSWORD_POLICY",
    "IAM_USER_MFA_ENABLED",
    "MFA_ENABLED_FOR_IAM_CONSOLE_ACCESS",
    "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED",
    "S3_BUCKET_LOGGING_ENABLED",
    "S3_BUCKET_PUBLIC_READ_PROHIBITED",
    "S3_BUCKET_PUBLIC_WRITE_PROHIBITED",
    "S3_BUCKET_VERSIONING_ENABLED",
    "EBS_ENCRYPTION_BY_DEFAULT",
    "ENCRYPTED_VOLUMES",
    "KMS_CMK_ROTATION_ENABLED",
    "RDS_STORAGE_ENCRYPTED",
    "RDS_SNAPSHOTS_PUBLIC_PROHIBITED",
    "GUARDDUTY_ENABLED_CENTRALIZED"
  ]
}

resource "aws_config_config_rule" "managed" {
  for_each = toset(local.managed_rules)
  name     = lower(each.value)
  source {
    owner             = "AWS"
    source_identifier = each.value
  }
  depends_on = [aws_config_configuration_recorder_status.status]
}
