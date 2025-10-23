terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 5.0" }
    awscc = { source = "hashicorp/awscc", version = ">= 0.66.0" }
  }
  backend "s3" {
    bucket         = var.tf_state_bucket
    key            = "states/${var.env}/terraform.tfstate"
    region         = var.region
    dynamodb_table = var.tf_lock_table
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}

provider "awscc" {
  region = var.region
}

variable "region" { type = string }
variable "env"    { type = string }
variable "name_prefix" { type = string }
variable "tf_state_bucket" { type = string }
variable "tf_lock_table" { type = string }
variable "logs_bucket_name" { type = string }

# Network
module "network" {
  source       = "../../network"
  vpc_cidr     = var.env == "prod" ? "10.0.0.0/16" : "10.1.0.0/16"
  name_prefix  = "${var.name_prefix}-${var.env}"
  region       = var.region
}

# Security (KMS, SecurityHub, GuardDuty)
module "security" {
  source   = "../../security"
  region   = var.region
  config_logs_bucket_name = var.logs_bucket_name
}

# Logging (CloudTrail + Logs S3 with Object Lock)
module "logging" {
  source           = "../../logging"
  region           = var.region
  logs_bucket_name = var.logs_bucket_name
  kms_key_arn      = module.security.kms_key_arn
}

# HealthLake FHIR Datastore
module "healthlake" {
  source       = "../../healthlake"
  region       = var.region
  kms_key_arn  = module.security.kms_key_arn
}