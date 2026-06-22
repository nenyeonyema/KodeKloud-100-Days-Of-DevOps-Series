# Task 94 — Create AWS VPC with Terraform

## Overview

> The Nautilus DevOps team is strategizing the migration of a portion of their infrastructure to the AWS cloud. Recognizing the scale of this undertaking, they have opted to approach the migration in incremental steps rather than as a single massive transition. To achieve this, they have segmented large tasks into smaller, more manageable units. This granular approach enables the team to execute the migration in gradual phases, ensuring smoother implementation and minimizing disruption to ongoing operations. By breaking down the migration into smaller tasks, the Nautilus DevOps team can systematically progress through each stage, allowing for better control, risk mitigation, and optimization of resources throughout the migration process.
> Create a VPC named xfusion-vpc in region us-east-1 with any IPv4 CIDR block through terraform.
> The Terraform working directory is /home/bob/terraform. Create the main.tf file (do not create a different .tf file) to accomplish this task.
Note: Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.i
>
---

## Infrastructure

| Resource | Value |
|----------|-------|
| Resource type | `aws_vpc` |
| VPC name (tag) | `xfusion-vpc` |
| Region | `us-east-1` |
| CIDR block | `10.0.0.0/16` |
| Terraform working dir | `/home/bob/terraform` |

---

## Files

```
/home/bob/terraform/
└── main.tf     # Single Terraform config file for this task
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

resource "aws_vpc" "xfusion_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "xfusion-vpc"
  }
}
```

### Configuration Breakdown

**`terraform` block:**

Declares the required AWS provider from the HashiCorp registry. `~> 5.0` means "any 5.x version" — it allows patch and minor updates but not a major version bump.

**`provider "aws"` block:**

Configures the AWS provider to deploy resources in `us-east-1` (N. Virginia). AWS credentials are sourced automatically from the environment (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`) or the IAM role attached to the instance — no credentials are hard-coded.

**`resource "aws_vpc" "xfusion_vpc"` block:**

| Argument | Value | Purpose |
|----------|-------|---------|
| `cidr_block` | `10.0.0.0/16` | IPv4 address range for the VPC (65,536 addresses) |
| `tags.Name` | `xfusion-vpc` | The name visible in the AWS console |

The local resource name `xfusion_vpc` (underscore) is Terraform's internal identifier. The actual AWS resource name comes from the `Name` tag (`xfusion-vpc` with a hyphen).

---

## Execution

```bash
cd /home/bob/terraform

# Step 1 — Download the AWS provider plugin and initialise the working directory
terraform init

# Step 2 — Preview what Terraform will create (no changes made)
terraform plan

# Step 3 — Create the VPC in AWS
terraform apply -auto-approve
```

### What each command does

| Command | Purpose |
|---------|---------|
| `terraform init` | Downloads the `hashicorp/aws` provider plugin into `.terraform/`; creates `.terraform.lock.hcl` |
| `terraform plan` | Compares desired state (main.tf) with current state (none yet) and shows what will be created |
| `terraform apply -auto-approve` | Executes the plan and creates the VPC; writes state to `terraform.tfstate` |

---

## Expected Output

**`terraform init`:**
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.x.x...

Terraform has been successfully initialized!
```

**`terraform apply -auto-approve`:**
```
Terraform used the selected providers to generate the following execution plan.

  # aws_vpc.xfusion_vpc will be created
  + resource "aws_vpc" "xfusion_vpc" {
      + cidr_block = "10.0.0.0/16"
      + id         = (known after apply)
      + tags       = {
          + "Name" = "xfusion-vpc"
        }
      ...
    }

Plan: 1 to add, 0 to change, 0 to destroy.

aws_vpc.xfusion_vpc: Creating...
aws_vpc.xfusion_vpc: Creation complete after 2s [id=vpc-xxxxxxxxxxxxxxxxx]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

---

## Verification

```bash
# Confirm state shows the VPC
terraform show

# List all resources Terraform is managing
terraform state list

# Verify in AWS CLI
aws ec2 describe-vpcs \
  --filters "Name=tag:Name,Values=xfusion-vpc" \
  --region us-east-1 \
  --query "Vpcs[*].{ID:VpcId,CIDR:CidrBlock,Name:Tags[?Key=='Name']|[0].Value}" \
  --output table
```

**Expected AWS CLI output:**
```
--------------------------------------------------
|                  DescribeVpcs                  |
+------------+----------------+------------------+
|    CIDR    |      ID        |      Name        |
+------------+----------------+------------------+
|10.0.0.0/16 |vpc-xxxxxxxxxx  | xfusion-vpc      |
+------------+----------------+------------------+
```

---

## Teardown (if needed)

```bash
cd /home/bob/terraform
terraform destroy -auto-approve
```

This removes the VPC from AWS and clears it from the Terraform state file.

---

## Key Terraform Concepts

| Concept | Detail |
|---------|--------|
| **Provider** | Plugin that lets Terraform manage a cloud platform (AWS, Azure, GCP) |
| **Resource** | A single piece of infrastructure to create/manage (`aws_vpc`, `aws_instance`, etc.) |
| **State file** | `terraform.tfstate` — records what Terraform has created; maps config to real resources |
| **CIDR block** | IP address range for the VPC; `10.0.0.0/16` gives 65,536 addresses across all subnets |
| **Tags** | AWS metadata key-value pairs; the `Name` tag sets the display name in the console |
| `~> 5.0` | Version constraint — allows `5.x` patches, blocks `6.0+` |

---

