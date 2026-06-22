# Task 96 - Launch EC2 Instance with Terraform

## Overview

> The Nautilus DevOps team is strategizing the migration of a portion of their infrastructure to the AWS cloud. Recognizing the scale of this undertaking, they have opted to approach the migration in incremental steps rather than as a single massive transition. To achieve this, they have segmented large tasks into smaller, more manageable units.
> For this task, create an EC2 instance using Terraform with the following requirements:
> The EC2 instance must use the value xfusion-ec2 as its Name tag, which defines the instance name in AWS.
Use the Amazon Linux ami-0c101f26f147fa7fd to launch this instance.
> The Instance type must be t2.micro.
> Create a new RSA key named xfusion-kp.
> Attach the default (available by default) security group.
> The Terraform working directory is /home/bob/terraform. Create the main.tf file (do not create a different .tf file) to provision the instance.
> Note: Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.
>


---

## Requirements

| Property | Value |
|----------|-------|
| Instance Name (tag) | `xfusion-ec2` |
| AMI | `ami-0c101f26f147fa7fd` (Amazon Linux) |
| Instance type | `t2.micro` |
| Key pair name | `xfusion-kp` (RSA, new) |
| Security group | Default security group |
| Region | `us-east-1` |
| Terraform working dir | `/home/bob/terraform` |

---

## Files

```
/home/bob/terraform/
└── main.tf     # Provider + TLS key + key pair + data source + EC2 instance
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

# Generate RSA private key
resource "tls_private_key" "xfusion_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS key pair using the generated public key
resource "aws_key_pair" "xfusion_kp" {
  key_name   = "xfusion-kp"
  public_key = tls_private_key.xfusion_key.public_key_openssh
}

# Fetch the default security group from the default VPC
data "aws_security_group" "default" {
  name = "default"
  filter {
    name   = "group-name"
    values = ["default"]
  }
}

# Launch EC2 instance
resource "aws_instance" "xfusion_ec2" {
  ami                    = "ami-0c101f26f147fa7fd"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.xfusion_kp.key_name
  vpc_security_group_ids = [data.aws_security_group.default.id]

  tags = {
    Name = "xfusion-ec2"
  }
}
```

---

## Configuration Breakdown

### Block 1 — `tls_private_key` (RSA key generation)

```hcl
resource "tls_private_key" "xfusion_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
```

Generates a 4096-bit RSA key pair **inside Terraform state**. This is handled by the `hashicorp/tls` provider (automatically available as a built-in provider — no extra `required_providers` entry needed).

| Argument | Value | Purpose |
|----------|-------|---------|
| `algorithm` | `RSA` | Key algorithm — matches the task requirement |
| `rsa_bits` | `4096` | Key length — 4096 is strong; 2048 is minimum acceptable |

The generated key exposes two attributes used downstream:
- `tls_private_key.xfusion_key.public_key_openssh` → uploaded to AWS
- `tls_private_key.xfusion_key.private_key_pem` → stored in Terraform state (sensitive)

### Block 2 — `aws_key_pair` (upload public key to AWS)

```hcl
resource "aws_key_pair" "xfusion_kp" {
  key_name   = "xfusion-kp"
  public_key = tls_private_key.xfusion_key.public_key_openssh
}
```

Creates the named key pair `xfusion-kp` in AWS by uploading the public key generated in Block 1. AWS stores only the public key — the private key never leaves Terraform state.

| Argument | Value | Purpose |
|----------|-------|---------|
| `key_name` | `xfusion-kp` | Name of the key pair in AWS — must match task requirement |
| `public_key` | `...public_key_openssh` | References the output of the `tls_private_key` resource |

### Block 3 — `data "aws_security_group"` (look up the default SG)

```hcl
data "aws_security_group" "default" {
  name = "default"
  filter {
    name   = "group-name"
    values = ["default"]
  }
}
```

A **data source** reads existing AWS infrastructure without creating anything. This fetches the pre-existing default security group from the default VPC so its ID can be referenced in the EC2 resource.

> **`data` vs `resource`:** `resource` blocks **create** infrastructure. `data` blocks **read** existing infrastructure. Since the default security group already exists in every AWS account, a data source is the correct approach here.

### Block 4 — `aws_instance` (the EC2 instance)

```hcl
resource "aws_instance" "xfusion_ec2" {
  ami                    = "ami-0c101f26f147fa7fd"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.xfusion_kp.key_name
  vpc_security_group_ids = [data.aws_security_group.default.id]

  tags = {
    Name = "xfusion-ec2"
  }
}
```

| Argument | Value | Purpose |
|----------|-------|---------|
| `ami` | `ami-0c101f26f147fa7fd` | Amazon Linux 2 AMI — region-specific, hard-coded as required |
| `instance_type` | `t2.micro` | Free-tier eligible instance size |
| `key_name` | `aws_key_pair.xfusion_kp.key_name` | References the key pair created in Block 2 |
| `vpc_security_group_ids` | `[data.aws_security_group.default.id]` | Attaches the default SG looked up in Block 3 |
| `tags.Name` | `xfusion-ec2` | The instance name shown in the AWS console |

`vpc_security_group_ids` is a list — even a single security group ID must be wrapped in `[ ]`.

---

## Resource Dependency Graph

Terraform automatically determines the order of resource creation from references:

```
tls_private_key.xfusion_key
        │
        │ .public_key_openssh
        ▼
aws_key_pair.xfusion_kp ──────────────────────┐
                                               │ .key_name
data.aws_security_group.default ───────────┐  │
                                           │  │ .id
                                           ▼  ▼
                                  aws_instance.xfusion_ec2
```

Terraform resolves these dependencies automatically — no `depends_on` is needed.

---

## Execution

```bash
cd /home/bob/terraform

# Initialise — downloads AWS and TLS providers
terraform init

# Preview the execution plan
terraform plan

# Create all resources
terraform apply -auto-approve
```

---

## Expected Output

```
Terraform used the selected providers to generate the following execution plan.

  # aws_instance.xfusion_ec2 will be created
  + resource "aws_instance" "xfusion_ec2" {
      + ami           = "ami-0c101f26f147fa7fd"
      + instance_type = "t2.micro"
      + key_name      = "xfusion-kp"
      + tags          = { "Name" = "xfusion-ec2" }
      ...
    }

  # aws_key_pair.xfusion_kp will be created
  + resource "aws_key_pair" "xfusion_kp" {
      + key_name   = "xfusion-kp"
      + public_key = (known after apply)
    }

  # tls_private_key.xfusion_key will be created
  + resource "tls_private_key" "xfusion_key" {
      + algorithm = "RSA"
      + rsa_bits  = 4096
    }

Plan: 3 to add, 0 to change, 0 to destroy.

tls_private_key.xfusion_key: Creating...
tls_private_key.xfusion_key: Creation complete after 0s
aws_key_pair.xfusion_kp: Creating...
aws_key_pair.xfusion_kp: Creation complete after 1s [id=xfusion-kp]
aws_instance.xfusion_ec2: Creating...
aws_instance.xfusion_ec2: Creation complete after 32s [id=i-xxxxxxxxxxxxxxxxx]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
```

---

## Verification

```bash
# Show full Terraform state
terraform show

# List all managed resources
terraform state list

# Verify the instance in AWS CLI
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=xfusion-ec2" \
  --region us-east-1 \
  --query "Reservations[*].Instances[*].{ID:InstanceId,Type:InstanceType,State:State.Name,AMI:ImageId,Key:KeyName}" \
  --output table

# Verify the key pair was created
aws ec2 describe-key-pairs \
  --filters "Name=key-name,Values=xfusion-kp" \
  --region us-east-1 \
  --output table
```

---

## Teardown (if needed)

```bash
cd /home/bob/terraform
terraform destroy -auto-approve
```

This terminates the EC2 instance, deletes the key pair from AWS, and removes the TLS key from Terraform state.

---

## Comparison — Tasks 94, 95, 96

| Detail | Task 94 | Task 95 | Task 96 |
|--------|---------|---------|---------|
| Resource | `aws_vpc` | `aws_security_group` | `aws_instance` |
| New concepts | VPC, CIDR | `ingress`/`egress` rules | `data` source, `tls_private_key`, key pair |
| Dependencies | None | None | 3-resource dependency chain |
| Data sources used | No | No | Yes — default SG lookup |

---

