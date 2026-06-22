# Task 97 — Create IAM Policy with Terraform

## Overview

> When establishing infrastructure on the AWS cloud, Identity and Access Management (IAM) is among the first and most critical services to configure. IAM facilitates the creation and management of user accounts, groups, roles, policies, and other access controls. The Nautilus DevOps team is currently in the process of configuring these resources and has outlined the following requirements.
> Create an IAM policy named iampolicy_john in us-east-1 region using Terraform. It must allow read-only access to the EC2 console, i.e., this policy must allow users to view all instances, AMIs, and snapshots in the Amazon EC2 console.
> The Terraform working directory is /home/bob/terraform. Create the main.tf file (do not create a different .tf file) to accomplish this task.
Note: Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the instance.

---

## Requirements

| Property | Value |
|----------|-------|
| Policy name | `iampolicy_john` |
| Region | `us-east-1` |
| Access level | Read-only (EC2 console) |
| Allowed views | Instances, AMIs, Snapshots |
| Terraform working dir | `/home/bob/terraform` |

---

## Files

```
/home/bob/terraform/
└── main.tf     # Provider + IAM policy resource
```

---

## Terraform Configuration — `/home/bob/terraform/main.tf`

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

resource "aws_iam_policy" "iampolicy_john" {
  name        = "iampolicy_john"
  description = "Read-only access to EC2 console — view instances, AMIs, and snapshots"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "ec2:GetConsoleOutput",
          "ec2:GetConsoleScreenshot"
        ]
        Resource = "*"
      }
    ]
  })
}
```

---

## Configuration Breakdown

### `aws_iam_policy` resource

```hcl
resource "aws_iam_policy" "iampolicy_john" {
  name        = "iampolicy_john"
  description = "..."
  policy      = jsonencode({ ... })
}
```

| Argument | Value | Purpose |
|----------|-------|---------|
| `name` | `iampolicy_john` | The IAM policy name — must match exactly (uses underscore, not hyphen) |
| `description` | Read-only EC2... | Human-readable description stored with the policy in AWS |
| `policy` | `jsonencode({...})` | The JSON policy document defining permissions |

### Policy Document — JSON Structure

The IAM policy document follows AWS's standard JSON policy language:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "ec2:GetConsoleOutput",
        "ec2:GetConsoleScreenshot"
      ],
      "Resource": "*"
    }
  ]
}
```

**Field breakdown:**

| Field | Value | Purpose |
|-------|-------|---------|
| `Version` | `"2012-10-17"` | IAM policy language version — always use this value |
| `Effect` | `"Allow"` | Grants the listed permissions (vs `"Deny"` which blocks them) |
| `Action` | `ec2:Describe*` etc. | The API actions permitted |
| `Resource` | `"*"` | Applies to all EC2 resources (required for Describe actions) |

### Why `ec2:Describe*` and not individual actions?

`ec2:Describe*` is a wildcard that covers all EC2 read/list operations, including:

| Action | What it allows viewing |
|--------|----------------------|
| `ec2:DescribeInstances` | All EC2 instances |
| `ec2:DescribeImages` | All AMIs |
| `ec2:DescribeSnapshots` | All EBS snapshots |
| `ec2:DescribeVolumes` | All EBS volumes |
| `ec2:DescribeSecurityGroups` | Security groups |
| `ec2:DescribeVpcs` | VPCs |
| `ec2:DescribeSubnets` | Subnets |
| ...and 200+ more `Describe` actions | All other EC2 read-only views |

Using `ec2:Describe*` ensures the policy covers everything needed to view the EC2 console without granting any write permissions. `ec2:GetConsoleOutput` and `ec2:GetConsoleScreenshot` are additional read-only actions that allow viewing instance console output — not covered by the `Describe*` wildcard.

### `jsonencode()` — Terraform's JSON helper

Rather than writing a raw JSON string (which requires escaping every quote), Terraform's `jsonencode()` function accepts native HCL objects and converts them to valid JSON at plan time. This makes the policy document easier to read, edit, and validate inside `main.tf`.
[O
```hcl
# With jsonencode — clean HCL syntax
policy = jsonencode({
  Version = "2012-10-17"
  Statement = [{ Effect = "Allow" ... }]
})

# Without jsonencode — hard to maintain
policy = "{\"Version\":\"2012-10-17\",\"Statement\":[...]}"
```

---

## Execution

```bash
cd /home/bob/terraform

# Initialise — downloads the AWS provider
terraform init

# Preview what will be created
terraform plan

# Create the IAM policy in AWS
terraform apply -auto-approve
```

---

## Expected Output

```
Terraform used the selected providers to generate the following execution plan.

  # aws_iam_policy.iampolicy_john will be created
  + resource "aws_iam_policy" "iampolicy_john" {
      + arn         = (known after apply)
      + id          = (known after apply)
      + name        = "iampolicy_john"
      + description = "Read-only access to EC2 console — view instances, AMIs, and snapshots"
      + policy      = jsonencode(
            {
              + Statement = [
                  + {
                      + Action   = [
                          + "ec2:Describe*",
                          + "ec2:GetConsoleOutput",
                          + "ec2:GetConsoleScreenshot",
                        ]
                      + Effect   = "Allow"
                      + Resource = "*"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
    }

Plan: 1 to add, 0 to change, 0 to destroy.

aws_iam_policy.iampolicy_john: Creating...
aws_iam_policy.iampolicy_john: Creation complete after 1s [id=arn:aws:iam::XXXXXXXXXXXX:policy/iampolicy_john]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

---

## Verification

```bash
# Show Terraform state
terraform show

# Verify via AWS CLI — list the policy
aws iam list-policies \
  --scope Local \
  --query "Policies[?PolicyName=='iampolicy_john'].{Name:PolicyName,ARN:Arn,Created:CreateDate}" \
  --output table

# Retrieve and view the full policy document
POLICY_ARN=$(aws iam list-policies --scope Local \
  --query "Policies[?PolicyName=='iampolicy_john'].Arn" \
  --output text)

VERSION_ID=$(aws iam get-policy \
  --policy-arn $POLICY_ARN \
  --query "Policy.DefaultVersionId" \
  --output text)

aws iam get-policy-version \
  --policy-arn $POLICY_ARN \
  --version-id $VERSION_ID \
  --query "PolicyVersion.Document" \
  --output json
```

**Expected policy document output:**
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:Describe*",
                "ec2:GetConsoleOutput",
                "ec2:GetConsoleScreenshot"
            ],
            "Resource": "*"
        }
    ]
}
```

---

## Teardown (if needed)

```bash
cd /home/bob/terraform
terraform destroy -auto-approve
```

---

## IAM Policy Concepts

### IAM Policy Types

| Type | Description | This task |
|------|-------------|-----------|
| **Managed policy** (AWS) | Pre-built by AWS, e.g. `AmazonEC2ReadOnlyAccess` | ❌ Task requires a custom policy |
| **Managed policy** (customer) | Custom policy created by the account | ✅ `iampolicy_john` |
| **Inline policy** | Embedded directly in a user/group/role | ❌ Not used here |

### Policy vs Role vs User

| IAM Concept | Purpose |
|-------------|---------|
| **Policy** | Defines *what* actions are allowed or denied |
| **User** | A person or service account |
| **Group** | A collection of users |
| **Role** | An identity assumed by services or users temporarily |
| **Attachment** | Links a policy to a user, group, or role |

This task creates only the policy. Attaching it to a user or group would be a subsequent step.

---

## Comparison — Tasks 94–97

| Task | Resource | Key Concept |
|------|----------|-------------|
| 94 | `aws_vpc` | Basic resource, CIDR block |
| 95 | `aws_security_group` | Inbound/outbound rules |
| 96 | `aws_instance` | Multi-resource dependency chain, data sources |
| 97 | `aws_iam_policy` | IAM, JSON policy documents, `jsonencode()` |

---

