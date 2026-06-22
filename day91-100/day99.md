# Task 99 — DynamoDB Table, IAM Role, and Policy with Terraform

## Overview

> The DevOps team has been tasked with creating a secure DynamoDB table and enforcing fine-grained access control using IAM. This setup will allow secure and restricted access to the table from trusted AWS services only.
> As a member of the Nautilus DevOps Team, your task is to perform the following using Terraform:
> Create a DynamoDB Table: Create a table named xfusion-table with minimal configuration.
> Create an IAM Role: Create an IAM role named xfusion-role that will be allowed to access the table.
> Create an IAM Policy: Create a policy named xfusion-readonly-policy that should grant read-only access (GetItem, Scan, Query) to the specific DynamoDB table and attach it to the role.
> Create the main.tf file (do not create a separate .tf file) to provision the table, role, and policy.
> Create the variables.tf file with the following variables:
> KKE_TABLE_NAME: name of the DynamoDB table
> KKE_ROLE_NAME: name of the IAM role
> KKE_POLICY_NAME: name of the IAM policy
> Create the outputs.tf file with the following outputs:
kke_dynamodb_table: name of the DynamoDB table
kke_iam_role_name: name of the IAM role
kke_iam_policy_name: name of the IAM policy
> Define the actual values for these variables in the terraform.tfvars file.
> Ensure that the IAM policy allows only read access and restricts it to the specific DynamoDB table created.
> Notes:
> The Terraform working directory is /home/bob/terraform.
Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.
> Before submitting the task, ensure that terraform plan returns No changes. Your infrastructure matches the configuration.
>
---

## Requirements

| Resource | Name | Key Config |
|----------|------|------------|
| DynamoDB Table | `xfusion-table` | Minimal config, PAY_PER_REQUEST billing |
| IAM Role | `xfusion-role` | Trust policy for AWS Lambda |
| IAM Policy | `xfusion-readonly-policy` | `GetItem`, `Scan`, `Query` on specific table ARN |
| Policy attachment | — | Policy attached to the role |

---

## Files

```
/home/bob/terraform/
├── main.tf             # All AWS resources
├── variables.tf        # Variable declarations (no defaults)
├── outputs.tf          # Output values after apply
└── terraform.tfvars    # Actual values for all variables
```

---

## `terraform.tfvars`

```hcl
KKE_TABLE_NAME  = "xfusion-table"
KKE_ROLE_NAME   = "xfusion-role"
KKE_POLICY_NAME = "xfusion-readonly-policy"
```

`terraform.tfvars` is the file where actual values are defined. Terraform automatically loads it at `plan` and `apply` time — no `-var-file` flag needed. The variable declarations in `variables.tf` have no `default` values, so all values **must** come from `terraform.tfvars`.

---

## `variables.tf`

```hcl
variable "KKE_TABLE_NAME" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "KKE_ROLE_NAME" {
  description = "Name of the IAM role"
  type        = string
}

variable "KKE_POLICY_NAME" {
  description = "Name of the IAM policy"
  type        = string
}
```

No `default` values are set — this makes the variables mandatory. Values are resolved exclusively from `terraform.tfvars`.

---

## `main.tf`

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# DynamoDB Table — minimal configuration
resource "aws_dynamodb_table" "xfusion_table" {
  name         = var.KKE_TABLE_NAME
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = var.KKE_TABLE_NAME
  }
}

# IAM Role — trust policy allows Lambda to assume this role
resource "aws_iam_role" "xfusion_role" {
  name = var.KKE_ROLE_NAME

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
[O    Name = var.KKE_ROLE_NAME
  }
}

# IAM Policy — read-only access scoped to the specific DynamoDB table ARN
resource "aws_iam_policy" "xfusion_readonly_policy" {
  name        = var.KKE_POLICY_NAME
  description = "Read-only access (GetItem, Scan, Query) to ${var.KKE_TABLE_NAME} DynamoDB table"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Resource = aws_dynamodb_table.xfusion_table.arn
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "xfusion_policy_attach" {
  role       = aws_iam_role.xfusion_role.name
  policy_arn = aws_iam_policy.xfusion_readonly_policy.arn
}
```

---

## `outputs.tf`

```hcl
output "kke_dynamodb_table" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.xfusion_table.name
}

output "kke_iam_role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.xfusion_role.name
}

output "kke_iam_policy_name" {
  description = "Name of the IAM policy"
  value       = aws_iam_policy.xfusion_readonly_policy.name
}
```

Note: output names use **lowercase** (`kke_dynamodb_table`) while variable names use **uppercase** (`KKE_TABLE_NAME`) — match the task spec exactly.

---

## Configuration Breakdown

### `aws_dynamodb_table` — Minimal Configuration

```hcl
resource "aws_dynamodb_table" "xfusion_table" {
  name         = var.KKE_TABLE_NAME
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}
```

| Argument | Value | Purpose |
|----------|-------|---------|
| `name` | `var.KKE_TABLE_NAME` | Table name from variable → `"xfusion-table"` |
| `billing_mode` | `PAY_PER_REQUEST` | On-demand billing — no provisioned capacity to configure |
| `hash_key` | `"id"` | Partition key — minimum required attribute for DynamoDB |
| `attribute.type` | `"S"` | String type — `S` (String), `N` (Number), `B` (Binary) |

`PAY_PER_REQUEST` is the minimal billing mode — no `read_capacity` or `write_capacity` values needed, keeping the config as simple as possible.

### `aws_iam_role` — Trust Policy (Assume Role Policy)

```hcl
assume_role_policy = jsonencode({
  Version = "2012-10-17"
  Statement = [{
    Effect    = "Allow"
    Principal = { Service = "lambda.amazonaws.com" }
    Action    = "sts:AssumeRole"
  }]
})
```

An IAM Role requires a **trust policy** (also called an assume role policy) that defines **who** can assume the role. This is separate from the permissions policy (which defines **what** the role can do).

| Trust Policy Field | Value | Purpose |
|-------------------|-------|---------|
| `Principal.Service` | `lambda.amazonaws.com` | Lambda functions can assume this role |
| `Action` | `sts:AssumeRole` | The specific STS action that grants role assumption |

### `aws_iam_policy` — Scoped to Specific Table ARN

```hcl
Resource = aws_dynamodb_table.xfusion_table.arn
```

The critical difference from Task 97 is **`Resource`**:

| Approach | Resource value | Scope |
|----------|---------------|-------|
| Task 97 (EC2 read-only) | `"*"` | All EC2 resources (required for Describe actions) |
| Task 99 (DynamoDB) | `aws_dynamodb_table.xfusion_table.arn` | **Only this specific table** |

Using the table ARN instead of `"*"` enforces the principle of least privilege — the role can only read from `xfusion-table`, not any other DynamoDB table in the account.

### `aws_iam_role_policy_attachment` — Linking Policy to Role

```hcl
resource "aws_iam_role_policy_attachment" "xfusion_policy_attach" {
  role       = aws_iam_role.xfusion_role.name
  policy_arn = aws_iam_policy.xfusion_readonly_policy.arn
}
```

This resource creates the association between the role and the policy. Without it, the policy exists but is not applied to anything.

| Argument | Value | Purpose |
|----------|-------|---------|
| `role` | `.name` of the IAM role | Which role to attach to |
| `policy_arn` | `.arn` of the IAM policy | Which policy to attach |

---

## Resource Dependency Graph

```
var.KKE_TABLE_NAME ──────────────────────────────────────────┐
var.KKE_ROLE_NAME ─────────────────────────────┐            │
var.KKE_POLICY_NAME ─────────────────┐         │            │
                                     │         │            │
                                     ▼         ▼            ▼
                          aws_iam_policy   aws_iam_role  aws_dynamodb_table
                          .xfusion_       .xfusion_     .xfusion_table
                          readonly_policy role              │ .arn
                               │ .arn      │ .name         │
                               └───────────┼───────────────┘
                                           ▼
                              aws_iam_role_policy_attachment
```

Terraform creates the DynamoDB table and IAM role first (in parallel), then creates the policy (which needs the table ARN), then attaches the policy to the role.

---

## Execution

```bash
cd /home/bob/terraform

terraform init
terraform plan
terraform apply -auto-approve

# Validate — required by the task
terraform plan
# Expected: No changes. Your infrastructure matches the configuration.
```

---

## Expected Output After Apply

```
Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

kke_dynamodb_table  = "xfusion-table"
kke_iam_policy_name = "xfusion-readonly-policy"
kke_iam_role_name   = "xfusion-role"
```

---

## Verification

```bash
# View all Terraform outputs
terraform output

# Verify DynamoDB table
aws dynamodb describe-table \
  --table-name xfusion-table \
  --region us-east-1 \
  --query "Table.{Name:TableName,Status:TableStatus,Billing:BillingModeSummary.BillingMode}" \
  --output table

# Verify IAM role
aws iam get-role \
  --role-name xfusion-role \
  --query "Role.{Name:RoleName,ARN:Arn}" \
  --output table

# Verify IAM policy and its document
POLICY_ARN=$(aws iam list-policies --scope Local \
  --query "Policies[?PolicyName=='xfusion-readonly-policy'].Arn" \
  --output text)

aws iam get-policy-version \
  --policy-arn $POLICY_ARN \
  --version-id v1 \
  --query "PolicyVersion.Document" \
  --output json

# Verify policy is attached to the role
aws iam list-attached-role-policies \
  --role-name xfusion-role \
  --output table
```

---

## Teardown (if needed)

```bash
cd /home/bob/terraform
terraform destroy -auto-approve
```

---

## Variables: `tfvars` vs `default` — When to Use Each

| Pattern | When to use |
|---------|-------------|
| `variables.tf` with `default` | Values that rarely change; safe to bake into code |
| `terraform.tfvars` (no default) | Environment-specific values; separates config from code |
| Environment variables (`TF_VAR_*`) | CI/CD pipelines; secrets that must not be in files |

This task uses `terraform.tfvars` without defaults — a clean separation of variable declaration (`variables.tf`) from value assignment (`terraform.tfvars`).

---

## Comparison — Tasks 94–99

| Task | Resources | New Concepts |
|------|-----------|--------------|
| 94 | `aws_vpc` | Basic resource |
| 95 | `aws_security_group` | Inbound/outbound rules |
| 96 | `aws_instance` | Data sources, key pairs, multi-resource deps |
| 97 | `aws_iam_policy` | IAM, `jsonencode()`, policy documents |
| 98 | VPC + subnet + SG + EC2 | `variables.tf`, `outputs.tf`, private networking |
| 99 | DynamoDB + IAM role + policy + attachment | `terraform.tfvars`, trust policies, scoped ARN, `aws_iam_role_policy_attachment` |

---

