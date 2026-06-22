# Task 91 — Install httpd and Deploy Web Page with lineinfile via Ansible

## Overview

> The Nautilus DevOps team want to install and set up a simple httpd web server on all app servers in Stratos DC. They also want to deploy a sample web page using Ansible. Therefore, write the required playbook to complete this task as per details mentioned below.
> We already have an inventory file under /home/thor/ansible directory on jump host. Write a playbook playbook.yml under /home/thor/ansible directory on jump host itself. Using the playbook perform below given tasks:
> Install httpd web server on all app servers, and make sure its service is up and running.
> Create a file /var/www/html/index.html with content:
> This is a Nautilus sample file, created using Ansible!
Using lineinfile Ansible module add some more content in /var/www/html/index.html file. Below is the content:
> Welcome to Nautilus Group!
> Also make sure this new line is added at the top of the file.
> The /var/www/html/index.html file's user and group owner should be apache on all app servers.
> The /var/www/html/index.html file's permissions should be 0744 on all app servers.
> Note: Validation will try to run the playbook using command ansible-playbook -i inventory playbook.yml so please make sure the playbook works this way without passing any extra arguments.

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

## Final State of `/var/www/html/index.html`

After the playbook runs, the file on each server will contain:

```
Welcome to Nautilus Group!
This is a Nautilus sample file, created using Ansible!
```

- Owner: `apache`
- Group: `apache`
- Permissions: `0744`

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
- name: Install httpd and deploy sample web page on all app servers
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

    - name: Create /var/www/html/index.html with initial content
      copy:
        content: "This is a Nautilus sample file, created using Ansible!\n"
        dest: /var/www/html/index.html
        owner: apache
        group: apache
        mode: '0744'

    - name: Add welcome line at the top of index.html using lineinfile
      lineinfile:
        path: /var/www/html/index.html
        line: "Welcome to Nautilus Group!"
        insertbefore: BOF

    - name: Ensure correct ownership and permissions on index.html
      file:
        path: /var/www/html/index.html
        owner: apache
        group: apache
        mode: '0744'
```

---

## Task Breakdown

### Task 1 — Install httpd

```yaml
yum:
  name: httpd
  state: present
```

Installs Apache via `yum`. Idempotent — skips if already installed.

### Task 2 — Start and Enable httpd Service

```yaml
service:
  name: httpd
  state: started
  enabled: yes
```

| Parameter | Purpose |
|-----------|---------|
| `state: started` | Starts the service immediately |
| `enabled: yes` | Ensures the service survives a reboot |

### Task 3 — Create index.html with Initial Content

```yaml
copy:
  content: "This is a Nautilus sample file, created using Ansible!\n"
  dest: /var/www/html/index.html
  owner: apache
  group: apache
  mode: '0744'
```

Uses the `copy` module with the inline `content` parameter (no source file needed) to write the first line of the page directly to the destination. Setting `owner`, `group`, and `mode` here ensures correct metadata is applied on file creation.

> `\n` at the end of `content` ensures a proper newline after the line, which `lineinfile` requires to correctly identify the beginning of the file when using `insertbefore: BOF`.

### Task 4 — Insert Line at Top with lineinfile

```yaml
lineinfile:
  path: /var/www/html/index.html
  line: "Welcome to Nautilus Group!"
  insertbefore: BOF
```

**Key `lineinfile` parameters:**

| Parameter | Value | Purpose |
|-----------|-------|---------|
| `path` | `/var/www/html/index.html` | File to modify |
| `line` | `"Welcome to Nautilus Group!"` | The line to insert |
| `insertbefore` | `BOF` | Insert **Before the first line** (Beginning Of File) |

`BOF` (Beginning Of File) is a special `lineinfile` keyword that places the new line before all existing content, making it the first line in the file. The alternative `insertafter: EOF` would add it at the bottom.

`lineinfile` is also idempotent — if the line already exists in the file, it will not be added again.

### Task 5 — Re-enforce Ownership and Permissions

```yaml
file:
  path: /var/www/html/index.html
  owner: apache
  group: apache
  mode: '0744'
```

`lineinfile` can reset file metadata after writing. This final `file` task guarantees `apache:apache` ownership and `0744` permissions are always in place after all content modifications are complete.

---

## Run the Playbook

```bash
cd /home/thor/ansible
ansible-playbook -i inventory playbook.yml
```

---

## Expected Output

```
PLAY [Install httpd and deploy sample web page on all app servers] **************

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

TASK [Create /var/www/html/index.html with initial content] ********************
changed: [stapp01]
changed: [stapp02]
changed: [stapp03]

TASK [Add welcome line at the top of index.html using lineinfile] **************
changed: [stapp01]
changed: [stapp02]
changed: [stapp03]

TASK [Ensure correct ownership and permissions on index.html] ******************
ok: [stapp01]
ok: [stapp02]
ok: [stapp03]

PLAY RECAP *********************************************************************
stapp01                    : ok=6    changed=4    unreachable=0    failed=0
stapp02                    : ok=6    changed=4    unreachable=0    failed=0
stapp03                    : ok=6    changed=4    unreachable=0    failed=0
```

---

## Verification

```bash
# Check file content — should show Welcome line first
ansible app_servers -i inventory -m shell -a "cat /var/www/html/index.html"

# Check ownership and permissions
ansible app_servers -i inventory -m shell -a "ls -la /var/www/html/index.html"

# Check httpd is running
ansible app_servers -i inventory -m shell -a "systemctl status httpd | grep Active"

# Test the web server responds
ansible app_servers -i inventory -m shell -a "curl -s http://localhost"
```

**Expected `cat` output:**
```
Welcome to Nautilus Group!
This is a Nautilus sample file, created using Ansible!
```

**Expected `ls -la` output:**
```
-rwxr--r-- 1 apache apache <size> <date> /var/www/html/index.html
```

---

## lineinfile vs blockinfile — Comparison

| Feature | `lineinfile` | `blockinfile` |
|---------|-------------|---------------|
| Inserts | A single line | A block of multiple lines |
| Markers | None | Wraps block with `# BEGIN/END ANSIBLE MANAGED BLOCK` |
| Position control | `insertbefore`, `insertafter`, regex | `insertbefore`, `insertafter` |
| BOF support | `insertbefore: BOF` | `insertbefore: BOF` |
| Best for | Single-line additions or replacements | Multi-line content blocks |
| Used in task | Task 91 | Task 88 |

---

## Modules Used

| Module | Purpose |
|--------|---------|
| `yum` | Install `httpd` on CentOS/RHEL |
| `service` | Start httpd now and enable on boot |
| `copy` | Create `index.html` with inline content |
| `lineinfile` | Insert `Welcome to Nautilus Group!` at the top of the file |
| `file` | Enforce `apache:apache` ownership and `0744` permissions |

---

