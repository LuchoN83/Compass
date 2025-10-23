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