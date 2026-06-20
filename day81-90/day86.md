# Task 86 — Passwordless SSH Setup for Ansible Controller

## Overview

> The Nautilus DevOps team is planning to test several Ansible playbooks on different app servers in Stratos DC. Before that, some pre-requisites must be met. Essentially, the team needs to set up a password-less SSH connection between Ansible controller and Ansible managed nodes. One of the tickets is assigned to you; please complete the task as per details mentioned below:
> a. Jump host is our Ansible controller, and we are going to run Ansible playbooks through thor user from jump host.
> b. There is an inventory file /home/thor/ansible/inventory on jump host. Using that inventory file test Ansible ping from jump host to App Server 2, make sure ping works.
>
---

## Infrastructure

| Role               | Host    | Hostname | IP Address    | SSH User |
|--------------------|---------|----------|---------------|----------|
| Ansible Controller | Jump Host | jump_host | —           | thor     |
| Managed Node       | App Server 2 | stapp02 | 172.16.238.11 | steve |

> App Server 2 sudo password: `Am3ric@`

---

## Inventory File

Location: `/home/thor/ansible/inventory` (pre-existing on the jump host)

```ini
[app_servers]
stapp01 ansible_host=172.16.238.10 ansible_user=tony
stapp02 ansible_host=172.16.238.11 ansible_user=steve
stapp03 ansible_host=172.16.238.12 ansible_user=banner

[app_servers:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

> Unlike Tasks 84/85, there are no `ansible_ssh_pass` entries here — passwordless SSH is required for Ansible to authenticate.

---

## Solution

### Step 1 — Switch to the thor User

All Ansible operations must run as `thor`, since that is the designated Ansible controller user.

```bash
sudo su - thor
```

### Step 2 — Generate an SSH Key Pair for thor

Check whether a key pair already exists, then generate one if not.

```bash
ls ~/.ssh/
```

If `id_rsa` and `id_rsa.pub` are absent:

```bash
ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -N ""
```

| Flag | Purpose |
|------|---------|
| `-t rsa` | Key type: RSA |
| `-b 2048` | Key length: 2048 bits |
| `-f ~/.ssh/id_rsa` | Output file path |
| `-N ""` | Empty passphrase — makes the key truly passwordless |

This produces two files:

```
~/.ssh/id_rsa       # Private key — stays on the jump host
~/.ssh/id_rsa.pub   # Public key — gets copied to managed nodes
```

### Step 3 — Copy the Public Key to App Server 2

`ssh-copy-id` appends thor's public key to `steve`'s `authorized_keys` file on `stapp02`. After this, SSH no longer needs a password.

```bash
ssh-copy-id -o StrictHostKeyChecking=no steve@stapp02
```

Enter ``password when prompted. This is the **last time** a password is needed.

**What this does under the hood:**

```
thor@jump_host:~/.ssh/id_rsa.pub  →  steve@stapp02:~/.ssh/authorized_keys
```

### Step 4 — Verify Passwordless SSH Manually (Optional but Recommended)

```bash
ssh steve@stapp02
```

If you get a shell prompt without a password prompt, the key-based auth is working correctly.

### Step 5 — Run the Ansible Ping to App Server 2

```bash
cd /home/thor/ansible
ansible stapp02 -i inventory -m ping
```

---

## Expected Output

```
stapp02 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
```

A `SUCCESS` with `"ping": "pong"` confirms:

- SSH connectivity is working
- The correct user (`steve`) is being used
- Python is available on the managed node (required for Ansible modules)

---

## How Ansible Ping Works

> The `ansible -m ping` module is **not** an ICMP network ping. It is an Ansible module that opens an SSH connection to the managed node, transfers a small Python script, executes it, and expects a `pong` response back. It validates the full Ansible communication stack in one command.

```
jump_host (thor)
     │
     │  SSH (key-based, no password)
     ▼
stapp02 (steve)
     │
     │  Executes ping module (Python)
     ▼
Returns "pong" → SUCCESS
```

---

## Verification

```bash
# Confirm the public key was copied
ssh steve@stapp02 "cat ~/.ssh/authorized_keys"

# Re-run the ping anytime to confirm connectivity
ansible stapp02 -i inventory -m ping
```

---

## How This Differs from Tasks 84 & 85

| Detail | Tasks 84 & 85 | Task 86 |
|--------|---------------|---------|
| Auth method | Password via `ansible_ssh_pass` in inventory | Passwordless SSH key-based auth |
| Inventory has passwords | Yes | No |
| SSH key setup required | No | Yes |
| Goal | Copy files to servers | Validate SSH connectivity |
| Ansible command | `ansible-playbook` | `ansible -m ping` |

---

