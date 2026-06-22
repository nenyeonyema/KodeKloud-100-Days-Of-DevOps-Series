# Task 98 — Private VPC, Subnet, and EC2 Instance with Terraform

## Overview

> The Nautilus DevOps team is expanding their AWS infrastructure and requires the setup of a private Virtual Private Cloud (VPC) along with a subnet. This VPC and subnet configuration will ensure that resources deployed within them remain isolated from external networks and can only communicate within the VPC. Additionally, the team needs to provision an EC2 instance under the newly created private VPC. This instance should be accessible only from within the VPC, allowing for secure communication and resource management within the AWS environment.
> Create a VPC named devops-priv-vpc with the CIDR block 10.0.0.0/16.
> Create a subnet named devops-priv-subnet inside the VPC with the CIDR block 10.0.1.0/24 and auto-assign IP option must not be enabled.
Create an EC2 instance named devops-priv-ec2 inside the subnet and instance type must be t2.micro.
> Ensure the security group of the EC2 instance allows access only from within the VPC's CIDR block.
> Create the main.tf file (do not create a separate .tf file) to provision the VPC, subnet and EC2 instance.
> Use variables.tf file with the following variable names:
> KKE_VPC_CIDR for the VPC CIDR block.
> KKE_SUBNET_CIDR for the subnet CIDR block.
> Use the outputs.tf file with the following variable names:
> KKE_vpc_name for the name of the VPC.
> KKE_subnet_name for the name of the subnet.
> KKE_ec2_private for the name of the EC2 instance.
> Notes:
> The Terraform working directory is /home/bob/terraform.
Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.
> Before submitting the task, ensure that terraform plan returns No changes. Your infrastructure matches the configuration.
>
---

## Requirements

| Resource | Name | Key Config |
|----------|------|------------|
| VPC | `devops-priv-vpc` | CIDR `10.0.0.0/16` |
| Subnet | `devops-priv-subnet` | CIDR `10.0.1.0/24`, no auto-assign IP |
| Security Group | `devops-priv-sg` | Inbound from VPC CIDR only |
| EC2 Instance | `devops-priv-ec2` | `t2.micro`, placed in the private subnet |

---

## Files

```
/home/bob/terraform/
├── main.tf         # All AWS resources — VPC, subnet, SG, EC2
├── variables.tf    # KKE_VPC_CIDR and KKE_SUBNET_CIDR
└── outputs.tf      # KKE_vpc_name, KKE_subnet_name, KKE_ec2_private
```

---

## `variables.tf`

```hcl
variable "KKE_VPC_CIDR" {
  description = "CIDR block for the private VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "KKE_SUBNET_CIDR" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.1.0/24"
}
```

Variables are referenced throughout `main.tf` as `var.KKE_VPC_CIDR` and `var.KKE_SUBNET_CIDR`. Defining CIDR blocks as variables avoids repetition — the VPC CIDR is used in both the `aws_vpc` resource and the security group `ingress` rule.

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

# VPC
resource "aws_vpc" "devops_priv_vpc" {
  cidr_block = var.KKE_VPC_CIDR

  tags = {
    Name = "devops-priv-vpc"
  }
}

# Subnet — auto-assign public IP disabled
resource "aws_subnet" "devops_priv_subnet" {
  vpc_id                  = aws_vpc.devops_priv_vpc.id
  cidr_block              = var.KKE_SUBNET_CIDR
  map_public_ip_on_launch = false

  tags = {
    Name = "devops-priv-subnet"
  }
}

# Security group — inbound only from within the VPC CIDR
resource "aws_security_group" "devops_priv_sg" {
  name        = "devops-priv-sg"
  description = "Allow access only from within the VPC CIDR block"
  vpc_id      = aws_vpc.devops_priv_vpc.id

  ingress {
    description = "Allow all traffic from within VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.KKE_VPC_CIDR]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-priv-sg"
  }
}

# EC2 instance inside the private subnet
resource "aws_instance" "devops_priv_ec2" {
  ami                    = "ami-0c101f26f147fa7fd"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.devops_priv_subnet.id
  vpc_security_group_ids = [aws_security_group.devops_priv_sg.id]

  tags = {
    Name = "devops-priv-ec2"
  }
}
```

---

## `outputs.tf`

```hcl
output "KKE_vpc_name" {
  description = "Name of the private VPC"
  value       = aws_vpc.devops_priv_vpc.tags["Name"]
}

output "KKE_subnet_name" {
  description = "Name of the private subnet"
  value       = aws_subnet.devops_priv_subnet.tags["Name"]
}

output "KKE_ec2_private" {
  description = "Name of the private EC2 instance"
  value       = aws_instance.devops_priv_ec2.tags["Name"]
}
```

Outputs expose values from Terraform state after `apply`. They are displayed in the terminal after a successful `apply` and queryable with `terraform output`. The output names must match the task spec exactly: `KKE_vpc_name`, `KKE_subnet_name`, `KKE_ec2_private`.

---

## Configuration Breakdown
[O
### `aws_subnet` — Private Subnet

```hcl
resource "aws_subnet" "devops_priv_subnet" {
  vpc_id                  = aws_vpc.devops_priv_vpc.id
  cidr_block              = var.KKE_SUBNET_CIDR
  map_public_ip_on_launch = false
  ...
}
```

| Argument | Value | Purpose |
|----------|-------|---------|
| `vpc_id` | `aws_vpc.devops_priv_vpc.id` | Places the subnet inside the custom VPC |
| `cidr_block` | `var.KKE_SUBNET_CIDR` → `10.0.1.0/24` | 256 IP addresses within the VPC range |
| `map_public_ip_on_launch` | `false` | Ensures no public IP is assigned to instances launched here |

`false` is actually the AWS default, but it is explicitly set here to satisfy the task requirement and make the intent clear.

### `aws_security_group` — VPC-internal Access Only

```hcl
ingress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = [var.KKE_VPC_CIDR]   # 10.0.0.0/16
}
```

Setting `cidr_blocks = [var.KKE_VPC_CIDR]` (i.e. `10.0.0.0/16`) on the inbound rule restricts all inbound traffic to originate only from IP addresses within the VPC's own address space. Traffic from the public internet (`0.0.0.0/0`) or other networks is blocked.

### `aws_instance` — Placed in the Private Subnet

```hcl
resource "aws_instance" "devops_priv_ec2" {
  ami                    = "ami-0c101f26f147fa7fd"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.devops_priv_subnet.id
  vpc_security_group_ids = [aws_security_group.devops_priv_sg.id]
  ...
}
```

`subnet_id` places the instance in the private subnet. Without a public IP (controlled by `map_public_ip_on_launch = false` on the subnet) and without an internet gateway, the instance is accessible only from within the VPC.

---

## Resource Dependency Graph

```
var.KKE_VPC_CIDR ──────────────────────────────────────┐
var.KKE_SUBNET_CIDR ──────────────────────┐            │
                                          │            │
aws_vpc.devops_priv_vpc ─────────────┬───┼────────────┤
         │ .id                       │   │            │
         ▼                           ▼   ▼            │
aws_subnet.devops_priv_subnet   aws_security_group     │
         │ .id                  .devops_priv_sg        │
         │                           │ .id             │
         └──────────────┬────────────┘                 │
                        ▼                              │
               aws_instance.devops_priv_ec2 ←─────────┘
```

Terraform resolves this entire dependency graph automatically from the resource references.

---

## Execution

```bash
cd /home/bob/terraform

# Initialise — downloads the AWS provider
terraform init

# Preview all resources to be created
terraform plan

# Apply — creates VPC, subnet, SG, and EC2 instance
terraform apply -auto-approve

# Confirm no drift (task requirement)
terraform plan
# Expected: No changes. Your infrastructure matches the configuration.
```

---

## Expected Output After Apply

```
Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

KKE_ec2_private = "devops-priv-ec2"
KKE_subnet_name = "devops-priv-subnet"
KKE_vpc_name    = "devops-priv-vpc"
```

---

## Verification

```bash
# View all outputs
terraform output

# Check specific output
terraform output KKE_vpc_name

# Verify VPC in AWS
aws ec2 describe-vpcs \
  --filters "Name=tag:Name,Values=devops-priv-vpc" \
  --region us-east-1 \
  --query "Vpcs[*].{ID:VpcId,CIDR:CidrBlock,Name:Tags[?Key=='Name']|[0].Value}" \
  --output table

# Verify subnet
aws ec2 describe-subnets \
  --filters "Name=tag:Name,Values=devops-priv-subnet" \
  --region us-east-1 \
  --query "Subnets[*].{ID:SubnetId,CIDR:CidrBlock,AutoIP:MapPublicIpOnLaunch}" \
  --output table

# Verify EC2 instance
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=devops-priv-ec2" \
  --region us-east-1 \
  --query "Reservations[*].Instances[*].{ID:InstanceId,Type:InstanceType,State:State.Name,Subnet:SubnetId}" \
  --output table
```

---

## Teardown (if needed)

```bash
cd /home/bob/terraform
terraform destroy -auto-approve
```

---

## Terraform File Roles — Summary

| File | Purpose |
|------|---------|
| `main.tf` | Core configuration — provider, resources |
| `variables.tf` | Input variables — parameterise CIDR values |
| `outputs.tf` | Output values — expose resource attributes after apply |
| `terraform.tfstate` | Auto-generated state file — do not edit manually |

---

## Comparison — Tasks 94–98

| Task | Resources | New Concepts |
|------|-----------|--------------|
| 94 | `aws_vpc` | Basic resource, tags |
| 95 | `aws_security_group` | `ingress`/`egress` blocks |
| 96 | `aws_instance`, `aws_key_pair`, `tls_private_key` | Data sources, multi-resource dependencies |
| 97 | `aws_iam_policy` | IAM, `jsonencode()`, policy documents |
| 98 | `aws_vpc`, `aws_subnet`, `aws_security_group`, `aws_instance` | `variables.tf`, `outputs.tf`, private networking, `map_public_ip_on_launch` |

---

