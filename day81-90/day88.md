# Task 88 — Install httpd and Deploy Sample Web Page via Ansible

## Overview

> The Nautilus DevOps team wants to install and set up a simple httpd web server on all app servers in Stratos DC. Additionally, they want to deploy a sample web page for now using Ansible only. Therefore, write the required playbook to complete this task. Find more details about the task below.
>
> We already have an inventory file under /home/thor/ansible directory on jump host. 
> Create a playbook.yml under /home/thor/ansible directory on jump host itself.
> Using the playbook, install httpd web server on all app servers. Additionally, make sure its service should up and running.
Using blockinfile Ansible module add some content in /var/www/html/index.html file. Below is the content:
> Welcome to XfusionCorp!
> This is  Nautilus sample file, created using Ansible!
Please do not modify this file manually!
> The /var/www/html/index.html file's user and group owner should be apache on all app servers.
> The /var/www/html/index.html file's permissions should be 0744 on all app servers.
> Note:
> i. Validation will try to run the playbook using command ansible-playbook -i inventory playbook.yml so please make sure the playbook works this way without passing any extra arguments.
> ii. Do not use any custom or empty marker for blockinfile module.
>
---

## Infrastructure

| Server       | Hostname | IP Address    | SSH User |
|--------------|----------|---------------|----------|
| App Server 1 | stapp01  | 172.16.238.10 | tony     |
| App Server 2 | stapp02  | 172.16.238.11 | steve    |
| App Server 3 | stapp03  | 172.16.238.12 | banner   |

> All servers run CentOS/RHEL. Sudo password: `Am3ric@`.

---

## Files

```
/home/thor/ansible/
├── inventory       # Pre-existing — all three app servers
└── playbook.yml    # Created for this task
```

---

## Inventory File — `/home/thor/ansible/inventory`

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

---

## Playbook — `/home/thor/ansible/playbook.yml`

```yaml
---
- name: Install and configure httpd web server on all app servers
  hosts: app_servers
  become: yes
  tasks:

    - name: Install httpd package
      yum:
        name: httpd
        state: present

    - name: Start and enable httpd service
      service:
        name: httpd
        state: started
        enabled: yes

    - name: Create /var/www/html/index.html with correct ownership and permissions
      file:
        path: /var/www/html/index.html
        state: touch
        owner: apache
        group: apache
        mode: '0744'

    - name: Add content to /var/www/html/index.html using blockinfile
      blockinfile:
        path: /var/www/html/index.html
        block: |
          Welcome to XfusionCorp!
          This is  Nautilus sample file, created using Ansible!
          Please do not modify this file manually!

    - name: Ensure correct ownership and permissions on index.html
      file:
        path: /var/www/html/index.html
        owner: apache
        group: apache
        mode: '0744'
```

---

## Task Breakdown — Each Step Explained

### Task 1 — Install httpd

```yaml
yum:
  name: httpd
  state: present
```

Installs the Apache web server using `yum` (CentOS/RHEL package manager). `state: present` is idempotent — skips if already installed.

### Task 2 — Start and Enable httpd Service

```yaml
service:
  name: httpd
  state: started
  enabled: yes
```

| Parameter | Purpose |
|-----------|---------|
| `state: started` | Ensures the service is running right now |
| `enabled: yes` | Ensures the service starts automatically on server reboot |

Both are needed — `started` alone won't survive a reboot; `enabled` alone won't start it immediately.

### Task 3 — Create index.html (file module)

```yaml
file:
  path: /var/www/html/index.html
  state: touch
  owner: apache
  group: apache
  mode: '0744'
```

Creates the file if it doesn't exist and sets initial ownership. `state: touch` is equivalent to the Unix `touch` command — creates an empty file without overwriting content if the file already exists.

### Task 4 — Add Content via blockinfile

```yaml
blockinfile:
  path: /var/www/html/index.html
  block: |
    Welcome to XfusionCorp!
    This is  Nautilus sample file, created using Ansible!
    Please do not modify this file manually!
```

The `blockinfile` module inserts a block of text into a file, wrapping it with default markers:

```
# BEGIN ANSIBLE MANAGED BLOCK
Welcome to XfusionCorp!
This is  Nautilus sample file, created using Ansible!
Please do not modify this file manually!
# END ANSIBLE MANAGED BLOCK
```

> **Important:** The task explicitly says **do not use any custom or empty marker**. Omitting the `marker` parameter means `blockinfile` uses its default markers — which is exactly what the validator expects. Setting `marker: ""` would break idempotency; setting a custom marker would fail validation.

> **Double space in line 2** (`This is  Nautilus`) is intentional — copied exactly as specified in the task to match the validation check.

### Task 5 — Re-apply Ownership and Permissions

```yaml
file:
  path: /var/www/html/index.html
  owner: apache
  group: apache
  mode: '0744'
```

`blockinfile` does not preserve file ownership set in a prior task, so this final `file` task enforces the required `apache:apache` owner and `0744` permissions after the content has been written.

**Permission breakdown — `0744`:**

| Scope | Permission | Meaning |
|-------|-----------|---------|
| Owner (apache) | `7` (rwx) | Read, write, execute |
| Group (apache) | `4` (r--) | Read only |
| Others | `4` (r--) | Read only |

---

## Run the Playbook

```bash
cd /home/thor/ansible
ansible-playbook -i inventory playbook.yml
```

---

## Expected Output

```
PLAY [Install and configure httpd web server on all app servers] ****************

TASK [Gathering Facts] *********************************************************
ok: [stapp01]
ok: [stapp02]
ok: [stapp03]

TASK [Install httpd package] ***************************************************
changed: [stapp01]
changed: [stapp02]
changed: [stapp03]

TASK [Start and enable httpd service] ******************************************
changed: [stapp01]
changed: [stapp02]
changed: [stapp03]

TASK [Create /var/www/html/index.html with correct ownership and permissions] **
changed: [stapp01]
changed: [stapp02]
changed: [stapp03]

TASK [Add content to /var/www/html/index.html using blockinfile] ***************
changed: [stapp01]
changed: [stapp02]
changed: [stapp03]

TASK [Ensure correct ownership and permissions on index.html] ******************
changed: [stapp01]
changed: [stapp02]
changed: [stapp03]

PLAY RECAP *********************************************************************
stapp01                    : ok=6    changed=5    unreachable=0    failed=0
stapp02                    : ok=6    changed=5    unreachable=0    failed=0
stapp03                    : ok=6    changed=5    unreachable=0    failed=0
```

---

## Verification

```bash
# Check httpd is running
ansible app_servers -i inventory -m shell -a "systemctl status httpd | grep Active"

# Check file content
ansible app_servers -i inventory -m shell -a "cat /var/www/html/index.html"

# Check ownership and permissions
ansible app_servers -i inventory -m shell -a "ls -la /var/www/html/index.html"
```

Expected `ls` output:
```
-rwxr--r-- 1 apache apache <size> <date> /var/www/html/index.html
```

---

## Modules Used — Summary

| Module | Purpose |
|--------|---------|
| `yum` | Install `httpd` package (CentOS/RHEL) |
| `service` | Start httpd now and enable it on boot |
| `file` | Create `index.html` and enforce ownership/permissions |
| `blockinfile` | Insert the required text block into `index.html` |

---

