# Task 95 — Create AWS Security Group with Terraform

## Overview

> The Nautilus DevOps team is strategizing the migration of a portion of their infrastructure to the AWS cloud. Recognizing the scale of this undertaking, they have opted to approach the migration in incremental steps rather than as a single massive transition. To achieve this, they have segmented large tasks into smaller, more manageable units. This granular approach enables the team to execute the migration in gradual phases, ensuring smoother implementation and minimizing disruption to ongoing operations. By breaking down the migration into smaller tasks, the Nautilus DevOps team can systematically progress through each stage, allowing for better control, risk mitigation, and optimization of resources throughout the migration process.
Use Terraform to create a security group under the default VPC with the following requirements:
> 1) The name of the security group must be devops-sg.
> 2) The description must be Security group for Nautilus App Servers.
> 3) Add an inbound rule of type HTTP, with a port range of 80, and source CIDR range 0.0.0.0/0.
> 4) Add another inbound rule of type SSH, with a port range of 22, and source CIDR range 0.0.0.0/0.
> Ensure that the security group is created in the us-east-1 region using Terraform. The Terraform working directory is /home/bob/terraform. Create the main.tf file (do not create a different .tf file) to accomplish this task.
Note: Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.
>
---

## Requirements

| Property | Value |
|----------|-------|
| Security group name | `devops-sg` |
| Description | `Security group for Nautilus App Servers` |
| Region | `us-east-1` |
| VPC | Default VPC |
| Terraform working dir | `/home/bob/terraform` |

### Inbound Rules

| Type | Protocol | Port | Source CIDR |
|------|----------|------|-------------|
| HTTP | tcp | 80 | 0.0.0.0/0 |
| SSH  | tcp | 22 | 0.0.0.0/0 |

---

## Files

```
/home/bob/terraform/
└── main.tf     # Single Terraform config file — provider + security group resource
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

resource "aws_security_group" "devops_sg" {
  name        = "devops-sg"
  description = "Security group for Nautilus App Servers"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-sg"
  }
}
```

---

## Configuration Breakdown

### `aws_security_group` resource

```hcl
resource "aws_security_group" "devops_sg" {
  name        = "devops-sg"
  description = "Security group for Nautilus App Servers"
```

| Argument | Value | Purpose |
|----------|-------|---------|
| `name` | `devops-sg` | The security group name in AWS — must match exactly |
| `description` | `"Security group for Nautilus App Servers"` | Required by AWS; cannot be changed after creation |

No `vpc_id` is specified — when omitted, AWS automatically places the security group in the **default VPC** of the region, which is what the task requires.

### `ingress` blocks — Inbound Rules

Each `ingress` block defines one inbound firewall rule:

```hcl
ingress {
  description = "HTTP"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
```

| Argument | Value | Purpose |
|----------|-------|---------|
| `from_port` | `80` / `22` | Start of port range |
| `to_port` | `80` / `22` | End of port range (same as `from_port` for single ports) |
| `protocol` | `"tcp"` | Transport protocol — HTTP and SSH both use TCP |
| `cidr_blocks` | `["0.0.0.0/0"]` | Allow traffic from any IPv4 address |

### `egress` block — Outbound Rule

```hcl
egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
```

`protocol = "-1"` means **all protocols**. `from_port = 0` and `to_port = 0` means **all ports**. Together this allows all outbound traffic — the AWS default egress behaviour. Without an explicit `egress` block, Terraform removes all outbound rules when managing security groups, which would break outbound connectivity.

---

## Execution

```bash
cd /home/bob/terraform

# Initialise — downloads the AWS provider plugin
terraform init

# Preview what Terraform will create
terraform plan

# Create the security group in AWS
terraform apply -auto-approve
```

---

## Expected Output

**`terraform apply -auto-approve`:**

```
Terraform used the selected providers to generate the following execution plan.

  # aws_security_group.devops_sg will be created
  + resource "aws_security_group" "devops_sg" {
      + description = "Security group for Nautilus App Servers"
      + id          = (known after apply)
      + name        = "devops-sg"

      + ingress {
          + description = "HTTP"
          + from_port   = 80
          + protocol    = "tcp"
          + to_port     = 80
          + cidr_blocks = ["0.0.0.0/0"]
        }

      + ingress {
          + description = "SSH"
          + from_port   = 22
          + protocol    = "tcp"
          + to_port     = 22
          + cidr_blocks = ["0.0.0.0/0"]
        }

      + egress {
          + from_port   = 0
          + protocol    = "-1"
          + to_port     = 0
          + cidr_blocks = ["0.0.0.0/0"]
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

aws_security_group.devops_sg: Creating...
aws_security_group.devops_sg: Creation complete after 2s [id=sg-xxxxxxxxxxxxxxxxx]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

---

## Verification

```bash
# View Terraform-managed state
terraform show

# Verify via AWS CLI
aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=devops-sg" \
  --region us-east-1 \
  --query "SecurityGroups[*].{ID:GroupId,Name:GroupName,Desc:Description,VPC:VpcId}" \
  --output table

# Check the inbound rules specifically
aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=devops-sg" \
  --region us-east-1 \
  --query "SecurityGroups[*].IpPermissions" \
  --output json
```

---

## Teardown (if needed)

```bash
cd /home/bob/terraform
terraform destroy -auto-approve
```

---

## Security Group Concepts

### How Security Groups Work in AWS

Security groups act as a **stateful virtual firewall** at the instance level:

- **Stateful** means if inbound traffic is allowed, the return traffic is automatically allowed regardless of outbound rules (unlike network ACLs which are stateless).
- **Inbound rules** control traffic entering instances attached to the security group.
- **Outbound rules** control traffic leaving those instances.
- By default, AWS security groups allow **all outbound** and **deny all inbound** traffic.

### Default VPC Placement

When `vpc_id` is omitted from `aws_security_group`, Terraform creates the security group in the **default VPC** of the configured region. Every AWS account has a default VPC per region created automatically by AWS.

---

## Comparison — Task 94 vs Task 95

| Detail | Task 94 | Task 95 |
|--------|---------|---------|
| Resource | `aws_vpc` | `aws_security_group` |
| Name | `xfusion-vpc` | `devops-sg` |
| Key arguments | `cidr_block` | `ingress`, `egress`, `description` |
| VPC | Created new | Uses default VPC |
| Region | `us-east-1` | `us-east-1` |
| File | `main.tf` only | `main.tf` only |

---

