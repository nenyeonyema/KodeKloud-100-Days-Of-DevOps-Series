# Task 85 — Ansible File Copy to Application Servers

## Overview

> The Nautilus DevOps team needs to copy data from the jump host to all application servers in Stratos DC using Ansible. Execute the task with the following details:
> a. Create an inventory file /home/thor/ansible/inventory on jump_host and add all application servers as managed nodes.
> b. Create a playbook /home/thor/ansible/playbook.yml on the jump host to copy the /usr/src/sysops/index.html file to all application servers, placing it at /opt/sysops.
> Note: Validation will run the playbook using the command ansible-playbook -i inventory playbook.yml. Ensure the playbook functions properly without any extra arguments.
>

---

## Infrastructure

| Server       | Hostname | IP Address    | SSH User |
|--------------|----------|---------------|----------|
| App Server 1 | stapp01  | 172.16.238.10 | tony     |
| App Server 2 | stapp02  | 172.16.238.11 | steve    |
| App Server 3 | stapp03  | 172.16.238.12 | banner   |

> All servers share the sudo password `Am3ric@`.

---

## Files Created

```
/home/thor/ansible/
├── inventory       # Defines all managed app server nodes
└── playbook.yml    # Copies index.html to /opt/sysops/ on each server
```

---

## Solution

### 1. Create the Working Directory

```bash
mkdir -p /home/thor/ansible
cd /home/thor/ansible
```

### 2. Inventory File — `/home/thor/ansible/inventory`

Defines the three application servers as managed nodes with SSH credentials and privilege escalation settings.

```ini
[app_servers]
stapp01 ansible_host=172.16.238.10 ansible_user=tony ansible_ssh_pass=Password
stapp02 ansible_host=172.16.238.11 ansible_user=steve ansible_ssh_pass=password
stapp03 ansible_host=172.16.238.12 ansible_user=banner ansible_ssh_pass=password

[app_servers:vars]
ansible_become=yes
ansible_become_method=sudo
ansible_become_pass=password
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

**Variable reference:**

| Variable | Purpose |
|---|---|
| `ansible_host` | Actual IP address of the server |
| `ansible_user` | SSH login user |
| `ansible_ssh_pass` | SSH password for the login user |
| `ansible_become` | Enables privilege escalation |
| `ansible_become_method` | Uses `sudo` for escalation |
| `ansible_become_pass` | Password for sudo |
| `ansible_ssh_common_args` | Suppresses SSH host key verification prompt |

### 3. Playbook — `/home/thor/ansible/playbook.yml`

Uses Ansible's `copy` module to push the file from the jump host to all app servers.

```yaml
---
- name: Copy index.html to all application servers
  hosts: app_servers
  become: yes
  tasks:
    - name: Copy /usr/src/sysops/index.html to /opt/sysops on app servers
      copy:
        src: /usr/src/sysops/index.html
        dest: /opt/sysops/
        mode: '0644'
```

**Playbook breakdown:**

| Key | Value | Purpose |
|---|---|---|
| `hosts` | `app_servers` | Targets all servers in the inventory group |
| `become` | `yes` | Runs tasks as root (required to write to `/opt/sysops/`) |
| `src` | `/usr/src/sysops/index.html` | Source file path on the jump host |
| `dest` | `/opt/sysops/` | Destination directory on each app server |
| `mode` | `0644` | Sets standard read/write permissions on the copied file |

> The trailing `/` on `dest` tells Ansible to place the file *inside* the directory rather than treat the path as a filename.

### 4. Run the Playbook

```bash
cd /home/thor/ansible
ansible-playbook -i inventory playbook.yml
```

---

## Expected Output

```
PLAY [Copy index.html to all application servers] ******************************

TASK [Gathering Facts] *********************************************************
ok: [stapp01]
ok: [stapp02]
ok: [stapp03]

TASK [Copy /usr/src/sysops/index.html to /opt/sysops on app servers] **********
changed: [stapp01]
changed: [stapp02]
changed: [stapp03]

PLAY RECAP *********************************************************************
stapp01                    : ok=2    changed=1    unreachable=0    failed=0
stapp02                    : ok=2    changed=1    unreachable=0    failed=0
stapp03                    : ok=2    changed=1    unreachable=0    failed=0
```

---

## Verification

Confirm the file was placed correctly on each server after the playbook run.

**Via SSH:**

```bash
ssh tony@stapp01    "ls -la /opt/sysops/index.html"
ssh steve@stapp02   "ls -la /opt/sysops/index.html"
ssh banner@stapp03  "ls -la /opt/sysops/index.html"
```

**Via Ansible ad-hoc (all servers at once):**

```bash
ansible app_servers -i inventory -m shell -a "ls -la /opt/sysops/index.html"
```

---

## How This Differs from Task 84

| Detail      | Task 84                   | Task 85                      |
|-------------|---------------------------|------------------------------|
| Source path | `/usr/src/dba/index.html` | `/usr/src/sysops/index.html` |
| Destination | `/opt/dba/`               | `/opt/sysops/`               |
| Inventory   | Identical                 | Identical                    |
| Playbook    | Same structure, different paths | Same structure, different paths |

The inventory structure and playbook pattern are identical between the two tasks — only the directory names change to reflect the team context (`dba` vs `sysops`).

---
