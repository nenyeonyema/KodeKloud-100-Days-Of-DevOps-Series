# Task 87 — Install zip Package on App Servers via Ansible

## Overview
> The Nautilus Application development team wanted to test some applications on app servers in Stratos Datacenter. They shared some pre-requisites with the DevOps team, and packages need to be installed on app servers. Since we are already using Ansible for automating such tasks, please perform this task using Ansible as per details mentioned below:
> Create an inventory file /home/thor/playbook/inventory on jump host and add all app servers in it.
> Create an Ansible playbook /home/thor/playbook/playbook.yml to install zip package on all  app servers using Ansible yum module.
Make sure user thor should be able to run the playbook on jump host.
> Note: Validation will try to run playbook using command ansible-playbook -i inventory playbook.yml so please make sure playbook works this way, without passing any extra arguments.
>
---

## Infrastructure

| Server       | Hostname | IP Address    | SSH User |
|--------------|----------|---------------|----------|
| App Server 1 | stapp01  | 172.16.238.10 | tony     |
| App Server 2 | stapp02  | 172.16.238.11 | steve    |
| App Server 3 | stapp03  | 172.16.238.12 | banner   |

> All servers share the sudo password `Am3ric@`. App servers run CentOS/RHEL, hence `yum` as the package manager.

---

## Files Created

```
/home/thor/playbook/
├── inventory       # All three app servers as managed nodes
└── playbook.yml    # Installs zip via the yum module
```

---

## Solution

### 1. Create the Working Directory

```bash
mkdir -p /home/thor/playbook
cd /home/thor/playbook
```

### 2. Inventory File — `/home/thor/playbook/inventory`

```ini
[app_servers]
stapp01 ansible_host=172.16.238.10 ansible_user=tony ansible_ssh_pass=password
stapp02 ansible_host=172.16.238.11 ansible_user=steve ansible_ssh_pass=password
stapp03 ansible_host=172.16.238.12 ansible_user=banner ansible_ssh_pass=password

[app_servers:vars]
ansible_become=yes
ansible_become_method=sudo
ansible_become_pass=password
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

### 3. Playbook — `/home/thor/playbook/playbook.yml`

```yaml
---
- name: Install zip package on all app servers
  hosts: app_servers
  become: yes
  tasks:
    - name: Install zip using yum
      yum:
        name: zip
        state: present
```

**Playbook breakdown:**

| Key | Value | Purpose |
|-----|-------|---------|
| `hosts` | `app_servers` | Targets all servers in the inventory group |
| `become` | `yes` | Runs the task as root — required for package installation |
| `yum` | module | Package manager for CentOS/RHEL app servers |
| `name` | `zip` | The package to install |
| `state` | `present` | Ensures the package is installed; skips if already present (idempotent) |

> `state: present` vs `state: latest` — `present` installs the package if missing and does nothing if it's already there. `latest` would also upgrade it if a newer version is available. For a deterministic install task, `present` is the correct choice.

### 4. Run the Playbook

```bash
cd /home/thor/playbook
ansible-playbook -i inventory playbook.yml
```

---

## Expected Output

```
PLAY [Install zip package on all app servers] **********************************

TASK [Gathering Facts] *********************************************************
ok: [stapp01]
ok: [stapp02]
ok: [stapp03]

TASK [Install zip using yum] ***************************************************
changed: [stapp01]
changed: [stapp02]
changed: [stapp03]

PLAY RECAP *********************************************************************
stapp01                    : ok=2    changed=1    unreachable=0    failed=0
stapp02                    : ok=2    changed=1    unreachable=0    failed=0
stapp03                    : ok=2    changed=1    unreachable=0    failed=0
```

If `zip` is already installed on a server, that host will show `ok=2 changed=0` instead — the `yum` module is idempotent and won't reinstall unnecessarily.

---

## Verification

After the playbook run, confirm `zip` is installed on each server:

**Via Ansible ad-hoc:**

```bash
ansible app_servers -i inventory -m shell -a "zip --version"
```

**Via SSH:**

```bash
ssh tony@stapp01   "zip --version"
ssh steve@stapp02  "zip --version"
ssh banner@stapp03 "zip --version"
```

---

## Key Differences from Previous Tasks

| Detail         | Tasks 84 & 85              | Task 87                        |
|----------------|----------------------------|--------------------------------|
| Ansible module | `copy`                     | `yum`                          |
| Goal           | Transfer a file            | Install a package              |
| Working dir    | `/home/thor/ansible/`      | `/home/thor/playbook/`         |
| `become`       | Required (write to `/opt`) | Required (package installation needs root) |
| Idempotent     | Yes (skips if file matches) | Yes (skips if package present) |

---

