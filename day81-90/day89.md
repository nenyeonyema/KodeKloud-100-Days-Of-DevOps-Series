# Task 89 — Install and Enable httpd on App Servers via Ansible

## Overview
> Developers are looking for dependencies to be installed and run on Nautilus app servers in Stratos DC. They have shared some requirements with the DevOps team. Because we are now managing packages installation and services management using Ansible, some playbooks need to be created and tested. As per details mentioned below please complete the task:
> a. On jump host create an Ansible playbook /home/thor/ansible/playbook.yml and configure it to install httpd on all app servers.
> b. After installation make sure to start and enable httpd service on all app servers.
> c. The inventory /home/thor/ansible/inventory is already there on jump host.
> d. Make sure user thor should be able to run the playbook on jump host.
> Note: Validation will try to run playbook using command ansible-playbook -i inventory playbook.yml so please make sure playbook works this way, without passing any extra arguments.
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
- name: Install and start httpd on all app servers
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
```

---

## Task Breakdown

### Task 1 — Install httpd

```yaml
yum:
  name: httpd
  state: present
```

Installs the Apache web server via `yum`, the package manager for CentOS/RHEL. Using `state: present` makes this idempotent — if `httpd` is already installed, Ansible skips the step without error.

### Task 2 — Start and Enable httpd Service

```yaml
service:
  name: httpd
  state: started
  enabled: yes
```

| Parameter | Purpose |
|-----------|---------|
| `state: started` | Starts the service immediately if it is not already running |
| `enabled: yes` | Registers the service with systemd so it starts automatically on every reboot |

Both parameters are required. `started` alone handles the current session but won't survive a reboot. `enabled: yes` alone registers the service for boot but doesn't start it immediately.

---

## Run the Playbook

```bash
cd /home/thor/ansible
ansible-playbook -i inventory playbook.yml
```

---

## Expected Output

```
PLAY [Install and start httpd on all app servers] ******************************

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

PLAY RECAP *********************************************************************
stapp01                    : ok=3    changed=2    unreachable=0    failed=0
stapp02                    : ok=3    changed=2    unreachable=0    failed=0
stapp03                    : ok=3    changed=2    unreachable=0    failed=0
```

---

## Verification

```bash
# Confirm httpd is active and enabled on all servers
ansible app_servers -i inventory -m shell -a "systemctl status httpd | grep -E 'Active|Loaded'"

# Check the httpd version installed
ansible app_servers -i inventory -m shell -a "httpd -v"
```

Expected status output per server:
```
Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; ...)
Active: active (running) since ...
```

---

## How This Relates to Task 88

Task 89 is a focused subset of Task 88. The table below shows what each task requires:

| Requirement                        | Task 88 | Task 89 |
|------------------------------------|---------|---------|
| Install httpd                      | ✅      | ✅      |
| Start and enable httpd service     | ✅      | ✅      |
| Create and populate index.html     | ✅      | ❌      |
| Set file ownership (apache:apache) | ✅      | ❌      |
| Set file permissions (0744)        | ✅      | ❌      |
| Use `blockinfile` module           | ✅      | ❌      |

---

## Modules Used

| Module    | Purpose                                      |
|-----------|----------------------------------------------|
| `yum`     | Install `httpd` package on CentOS/RHEL       |
| `service` | Start httpd now and enable it on boot        |

---

