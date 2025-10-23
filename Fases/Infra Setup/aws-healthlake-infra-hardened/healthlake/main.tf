terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = ">= 0.66.0"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "awscc" {
  region = var.region
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-2"
}

variable "datastore_name" {
  type        = string
  description = "Name for the FHIR Datastore"
  default     = "cosight-healthlake"
}

variable "kms_key_arn" {
  type        = string
  description = "KMS CMK ARN for HealthLake encryption"
}

# AWS Cloud Control API resource for HealthLake FHIR Datastore
resource "awscc_healthlake_fhir_datastore" "this" {
  datastore_name = var.datastore_name
  datastore_type_version = "R4"
  sse_configuration = {
    kms_key_id = var.kms_key_arn
  }
}

output "healthlake_datastore_id" { value = awscc_healthlake_fhir_datastore.this.id }