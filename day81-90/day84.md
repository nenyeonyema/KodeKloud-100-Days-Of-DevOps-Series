# Task 84 — Ansible File Copy to Application Servers

## Overview
> The Nautilus DevOps team needs to copy data from the jump host to all application servers in Stratos DC using Ansible. Execute the task with the following details:
>
> a. Create an inventory file /home/thor/ansible/inventory on jump_host and add all application servers as managed nodes.
>
> b. Create a playbook /home/thor/ansible/playbook.yml on the jump host to copy the /usr/src/dba/index.html file to all application servers, placing it at /opt/dba.
>
> Note: Validation will run the playbook using the command ansible-playbook -i inventory playbook.yml. Ensure the playbook functions properly without any extra arguments.

---

## Infrastructure

| Server   | Hostname | IP Address      | User   |
|----------|----------|-----------------|--------|
| App Server 1 | stapp01  | 172.16.238.10   | tony   |
| App Server 2 | stapp02  | 172.16.238.11   | steve  |
| App Server 3 | stapp03  | 172.16.238.12   | banner |

> All servers share the sudo password `Am3ric@`.

---

## Files Created

```
/home/thor/ansible/
├── inventory       # Defines all managed app server nodes
└── playbook.yml    # Copies index.html to /opt/dba/ on each server
```

---

## Solution

### 1. Create the Working Directory

```bash
mkdir -p /home/thor/ansible
cd /home/thor/ansible
```

### 2. Inventory File — `/home/thor/ansible/inventory`

Defines the three application servers as managed nodes, including SSH credentials and privilege escalation settings.

```ini
[app_servers]
stapp01 ansible_host=172.16.238.10 ansible_user=tony ansible_ssh_pass=Password
stapp02 ansible_host=172.16.238.11 ansible_user=steve ansible_ssh_pass=Password
stapp03 ansible_host=172.16.238.12 ansible_user=banner ansible_ssh_pass=Password

[app_servers:vars]
ansible_become=yes
ansible_become_method=sudo
ansible_become_pass=Password
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

**Key variables explained:**

| Variable | Purpose |
|---|---|
| `ansible_host` | Actual IP address of the server |
| `ansible_user` | SSH login user |
| `ansible_ssh_pass` | SSH password |
| `ansible_become` | Enables privilege escalation (sudo) |
| `ansible_become_method` | Uses `sudo` for escalation |
| `ansible_become_pass` | Password for sudo |
| `ansible_ssh_common_args` | Skips SSH host key verification prompt |

### 3. Playbook — `/home/thor/ansible/playbook.yml`

Uses the `copy` module to push the file from the jump host to all app servers.

```yaml
---
- name: Copy index.html to all application servers
  hosts: app_servers
  become: yes
  tasks:
    - name: Copy /usr/src/dba/index.html to /opt/dba on app servers
      copy:
        src: /usr/src/dba/index.html
        dest: /opt/dba/
        mode: '0644'
```

**Playbook breakdown:**

- `hosts: app_servers` — targets all servers defined in the `[app_servers]` inventory group
- `become: yes` — runs tasks with elevated privileges (required to write to `/opt/dba/`)
- `copy` module — copies a file from the **control node** (jump host) to each **managed node**
- `src` — source path on the jump host
- `dest` — destination directory on each app server (trailing `/` ensures the file is placed *inside* the directory, not renamed)
- `mode: '0644'` — sets standard read/write file permissions

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

TASK [Copy /usr/src/dba/index.html to /opt/dba on app servers] ****************
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

After the playbook runs, confirm the file was copied successfully on each server:

```bash
# Check on each app server
ssh tony@stapp01 "ls -la /opt/dba/index.html"
ssh steve@stapp02 "ls -la /opt/dba/index.html"
ssh banner@stapp03 "ls -la /opt/dba/index.html"
```

Or use Ansible ad-hoc to check all at once:

```bash
ansible app_servers -i inventory -m shell -a "ls -la /opt/dba/index.html"
```
---
