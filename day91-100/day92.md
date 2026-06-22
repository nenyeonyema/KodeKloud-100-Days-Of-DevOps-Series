# Task 92 — Ansible Role with Jinja2 Template for httpd Deployment

## Overview
> One of the Nautilus DevOps team members is working on to develop a role for httpd installation and configuration. Work is almost completed, however there is a requirement to add a jinja2 template for index.html file. Additionally, the relevant task needs to be added inside the role. The inventory file ~/ansible/inventory is already present on jump host that can be used. Complete the task as per details mentioned below:
> a. Update ~/ansible/playbook.yml playbook to run the httpd role on App Server 3.
> b. Create a jinja2 template index.html.j2 under /home/thor/ansible/role/httpd/templates/ directory and add a line This file was created using Ansible on <respective server> (for example This file was created using Ansible on stapp01 in case of App Server 1). Also please make sure not to hard code the server name inside the template. Instead, use inventory_hostname variable to fetch the correct value.
> c. Add a task inside /home/thor/ansible/role/httpd/tasks/main.yml to copy this template on App Server 3 under /var/www/html/index.html. Also make sure that /var/www/html/index.html file's permissions are 0655.
> d. The user/group owner of /var/www/html/index.html file must be respective sudo user of the server (for example tony in case of stapp01).
> Note: Validation will try to run the playbook using command ansible-playbook -i inventory playbook.yml so please make sure the playbook works this way without passing any extra arguments.

---

## Infrastructure

| Server       | Hostname | IP Address    | SSH User | Role Target |
|--------------|----------|---------------|----------|-------------|
| App Server 1 | stapp01  | 172.16.238.10 | tony     | ❌          |
| App Server 2 | stapp02  | 172.16.238.11 | steve    | ❌          |
| App Server 3 | stapp03  | 172.16.238.12 | banner   | ✅          |

> Sudo user for App Server 3 is `banner`. File owner/group must be `banner`.

---

## Files Created / Modified

```
/home/thor/ansible/
├── inventory                              # Pre-existing — unchanged
├── playbook.yml                           # Updated to run httpd role on stapp03
└── role/
    └── httpd/
        ├── tasks/
        │   └── main.yml                   # Updated — added template deploy task
        └── templates/
            └── index.html.j2              # Created — Jinja2 template
```

---

## Final State of `/var/www/html/index.html` on stapp03

```
This file was created using Ansible on stapp03
```

- Owner: `banner`
- Group: `banner`
- Permissions: `0655`

---

## Solution

### 1. Create the Role Directory Structure

```bash
mkdir -p /home/thor/ansible/role/httpd/tasks
mkdir -p /home/thor/ansible/role/httpd/templates
mkdir -p /home/thor/ansible/role/httpd/handlers
mkdir -p /home/thor/ansible/role/httpd/vars
mkdir -p /home/thor/ansible/role/httpd/defaults
mkdir -p /home/thor/ansible/role/httpd/meta
```

### 2. Jinja2 Template — `role/httpd/templates/index.html.j2`

```jinja2
This file was created using Ansible on {{ inventory_hostname }}
```

**Key design decision — `inventory_hostname` not hard-coded:**

| Approach | Value on stapp03 | Reusable across servers |
|----------|-----------------|------------------------|
| Hard-coded `stapp03` | `stapp03` | ❌ breaks on stapp01/02 |
| `{{ inventory_hostname }}` | `stapp03` | ✅ resolves correctly per host |
| `{{ ansible_hostname }}` | actual OS hostname | ⚠️ may differ from inventory name |

`inventory_hostname` is the name of the host **as defined in the inventory file**, making it the safest and most explicit choice here.

### 3. Role Tasks — `role/httpd/tasks/main.yml`

```yaml
---
- name: Install httpd package
  yum:
    name: httpd
    state: present

- name: Start and enable httpd service
  service:
    name: httpd
    state: started
    enabled: yes

- name: Deploy index.html from Jinja2 template
  template:
    src: index.html.j2
    dest: /var/www/html/index.html
    owner: "{{ ansible_user }}"
    group: "{{ ansible_user }}"
    mode: '0655'
```

**`template` module parameters:**

| Parameter | Value | Purpose |
|-----------|-------|---------|
| `src` | `index.html.j2` | Template file — Ansible looks in `templates/` automatically |
| `dest` | `/var/www/html/index.html` | Destination path on the managed node |
| `owner` | `{{ ansible_user }}` | Resolves to `banner` for stapp03 from the inventory |
| `group` | `{{ ansible_user }}` | Same — sets group to `banner` |
| `mode` | `0655` | rwxr-xr-x for owner, r-xr-x for group and others |

> `ansible_user` is automatically populated from `ansible_user=banner` in the inventory, so it correctly maps to the sudo user of each server without any hard-coding.

**Permission breakdown — `0655`:**

| Scope | Permission | Meaning |
|-------|------------|---------|
| Owner (banner) | `6` (rw-) | Read and write |
| Group (banner) | `5` (r-x) | Read and execute |
| Others | `5` (r-x) | Read and execute |

### 4. Updated Playbook — `/home/thor/ansible/playbook.yml`

```yaml
---
- name: Run httpd role on App Server 3
  hosts: stapp03
  become: yes
  roles:
    - role: /home/thor/ansible/role/httpd
```

The absolute path to the role (`/home/thor/ansible/role/httpd`) is used because the role is not in a standard Ansible roles path (`/etc/ansible/roles` or `~/.ansible/roles`). This makes it work without needing `ansible.cfg` configuration.

---

## Run the Playbook

```bash
cd /home/thor/ansible
ansible-playbook -i inventory playbook.yml
```

---

## Expected Output

```
PLAY [Run httpd role on App Server 3] ******************************************

TASK [Gathering Facts] *********************************************************
ok: [stapp03]

TASK [/home/thor/ansible/role/httpd : Install httpd package] *******************
changed: [stapp03]

TASK [/home/thor/ansible/role/httpd : Start and enable httpd service] **********
changed: [stapp03]

TASK [/home/thor/ansible/role/httpd : Deploy index.html from Jinja2 template] *
changed: [stapp03]

PLAY RECAP *********************************************************************
stapp03                    : ok=4    changed=3    unreachable=0    failed=0
```

---

## Verification

```bash
# Check rendered file content
ansible stapp03 -i inventory -m shell -a "cat /var/www/html/index.html"
# Expected: This file was created using Ansible on stapp03

# Check ownership and permissions
ansible stapp03 -i inventory -m shell -a "ls -la /var/www/html/index.html"
# Expected: -rw-r-xr-x 1 banner banner ... index.html

# Confirm httpd is running
ansible stapp03 -i inventory -m shell -a "systemctl status httpd | grep Active"

# Test web server response
ansible stapp03 -i inventory -m shell -a "curl -s http://localhost"
```

---

## How the `template` Module Differs from `copy`

| Feature | `copy` module | `template` module |
|---------|--------------|-------------------|
| Source | Static file or inline `content` | Jinja2 `.j2` template file |
| Variable substitution | ❌ No | ✅ Yes — `{{ var }}` replaced at runtime |
| Source file location | Anywhere, or inline | `templates/` directory inside the role |
| Use case | Exact file copy | Dynamic files whose content varies per host |
| File extension | Any | `.j2` convention (stripped from dest) |

---

## Ansible Role Structure Reference

```
role/httpd/
├── tasks/        ← main.yml: list of tasks to execute
├── templates/    ← .j2 Jinja2 template files
├── handlers/     ← tasks triggered by notify (e.g. restart httpd)
├── vars/         ← variables with high precedence
├── defaults/     ← default variables (lowest precedence)
└── meta/         ← role metadata (dependencies, author, etc.)
```

When using the `template` module inside a role, Ansible automatically looks in the role's `templates/` directory for the `src` file — no need to specify the full path.

---

## Modules Used

| Module | Purpose |
|--------|---------|
| `yum` | Install `httpd` on CentOS/RHEL |
| `service` | Start httpd and enable on boot |
| `template` | Render Jinja2 template and deploy to managed node |

---

