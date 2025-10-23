# AWS HealthLake – Terraform Infrastructure

Bilingual repository (EN/ES) for provisioning the **AWS HealthLake** baseline architecture with **security best practices** and **GitHub Actions DevSecOps pipeline**.

## Structure / Estructura
```
aws-healthlake-infra/
├── bootstrap/              # Remote state S3 + DynamoDB (one-time)
├── network/                # VPC, subnets, endpoints
├── security/               # KMS, IAM baseline, SecurityHub, GuardDuty
├── logging/                # CloudTrail, central logs S3 (Object Lock)
├── healthlake/             # HealthLake FHIR Datastore (AWSCC)
├── environments/
│   ├── prod/
│   └── nonprod/
└── .github/workflows/      # CI/CD with checks & OIDC to AWS
```

> **Note:** Backends (S3) are per account; run `bootstrap` first in each account.