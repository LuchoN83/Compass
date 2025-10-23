# Using AWS Secrets Manager with Terraform (Examples)

This repo shows how to reference sensitive values (e.g., KMS ARNs, partner endpoints) 
from **AWS Secrets Manager** instead of hardcoding variables.

## Example Secret JSON (store in Secrets Manager)
Secret name: `cosight/infra/shared`

```json
{
  "kms_arn": "arn:aws:kms:eu-west-2:111122223333:key/abcd-1234-...",
  "healthlake_datastore_name": "cosight-healthlake",
  "classification_tag": "gdpr-restricted"
}
```

## Terraform example

```hcl
data "aws_secretsmanager_secret_version" "shared" {
  secret_id = "cosight/infra/shared"
}

locals {
  shared = jsondecode(data.aws_secretsmanager_secret_version.shared.secret_string)
}

# Use the secret values
module "healthlake" {
  source      = "../../healthlake"
  region      = var.region
  kms_key_arn = local.shared.kms_arn
  datastore_name = local.shared.healthlake_datastore_name
}

# Example tagging using classification from secret
resource "aws_s3_bucket" "example" {
  bucket = "cosight-example-${var.env}"
  tags = {
    DataClassification = local.shared.classification_tag
    Project            = "AWS-HealthLake"
  }
}
```

> Ensure the GitHub OIDC role has **secretsmanager:GetSecretValue** permission for the specific secret ARN.