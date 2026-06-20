# Task 90 — Create Files with ACL Permissions via Ansible

## Overview

The Nautilus DevOps team needs to create specific files on each app server in Stratos DC, owned by `root`, and grant targeted ACL (Access Control List) permissions to specific users and groups on each file — all automated through a single Ansible playbook.

---

## Requirements Summary

| Server   | File                     | ACL Entity | Entity Type | Permissions |
|----------|--------------------------|------------|-------------|-------------|
| stapp01  | `/opt/security/blog.txt`  | tony       | group       | `r`         |
| stapp02  | `/opt/security/story.txt` | steve      | user        | `rw`        |
| stapp03  | `/opt/security/media.txt` | banner     | group       | `rw`        |

> All files are owned by `root:root`. ACL permissions are applied on top of standard Unix permissions.

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
└── playbook.yml    # Created for this task — three separate plays
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

The playbook uses **three separate plays**, one per server, since each server requires a different file and different ACL configuration.

```yaml
---
# Play 1 — App Server 1: blog.txt with ACL read for group tony
- name: Create blog.txt on App Server 1 and set ACL
  hosts: stapp01
  become: yes
  tasks:

    - name: Ensure /opt/security directory exists on stapp01
      file:
        path: /opt/security
        state: directory
        owner: root
        group: root
        mode: '0755'

    - name: Create empty file blog.txt on stapp01
      file:
        path: /opt/security/blog.txt
        state: touch
        owner: root
        group: root
        mode: '0644'

    - name: Set ACL - read permission for group tony on blog.txt
      acl:
        path: /opt/security/blog.txt
        entity: tony
        etype: group
        permissions: r
        state: present

# Play 2 — App Server 2: story.txt with ACL read+write for user steve
- name: Create story.txt on App Server 2 and set ACL
  hosts: stapp02
  become: yes
  tasks:

    - name: Ensure /opt/security directory exists on stapp02
      file:
        path: /opt/security
        state: directory
        owner: root
        group: root
        mode: '0755'

    - name: Create empty file story.txt on stapp02
      file:
        path: /opt/security/story.txt
        state: touch
        owner: root
        group: root
        mode: '0644'

    - name: Set ACL - read+write permission for user steve on story.txt
      acl:
        path: /opt/security/story.txt
        entity: steve
        etype: user
        permissions: rw
        state: present

# Play 3 — App Server 3: media.txt with ACL read+write for group banner
- name: Create media.txt on App Server 3 and set ACL
  hosts: stapp03
  become: yes
  tasks:

    - name: Ensure /opt/security directory exists on stapp03
      file:
        path: /opt/security
        state: directory
        owner: root
        group: root
        mode: '0755'

    - name: Create empty file media.txt on stapp03
      file:
        path: /opt/security/media.txt
        state: touch
        owner: root
        group: root
        mode: '0644'

    - name: Set ACL - read+write permission for group banner on media.txt
      acl:
        path: /opt/security/media.txt
        entity: banner
        etype: group
        permissions: rw
        state: present
```

---

## Task Breakdown

### Why Three Separate Plays?

Each app server has a **different file** and a **different ACL requirement**. Using `hosts: stapp01`, `hosts: stapp02`, `hosts: stapp03` in separate plays ensures each set of tasks runs only against its intended target. A single play with `hosts: app_servers` would attempt to create all three files on all three servers, which is incorrect.

### Task 1 per Play — Ensure Directory Exists

```yaml
file:
  path: /opt/security
  state: directory
  owner: root
  group: root
  mode: '0755'
```

Creates `/opt/security/` if it doesn't exist. Without this, the subsequent `touch` task would fail because the parent directory is missing. `state: directory` is idempotent — safe to run even if it already exists.

### Task 2 per Play — Create the Empty File

```yaml
file:
  path: /opt/security/blog.txt   # or story.txt / media.txt
  state: touch
  owner: root
  group: root
  mode: '0644'
```

Creates an empty file owned by `root:root`. `state: touch` mirrors Unix `touch` — creates the file if absent, updates timestamps if present, never overwrites content.

### Task 3 per Play — Apply ACL with the `acl` Module

```yaml
acl:
  path: /opt/security/blog.txt
  entity: tony
  etype: group
  permissions: r
  state: present
```

**ACL module parameters:**

| Parameter | Purpose |
|-----------|---------|
| `path` | File to apply the ACL entry to |
| `entity` | The user or group name receiving the permission |
| `etype` | Entity type — `user` or `group` |
| `permissions` | Unix permission string: `r`, `w`, `rw`, `rwx`, etc. |
| `state: present` | Adds the ACL entry; use `absent` to remove it |

---

## ACL vs Standard Unix Permissions

Standard Unix permissions only support three permission sets: owner, group, others. ACLs extend this by allowing fine-grained per-user or per-group permissions on top of the standard model.

```
Standard permissions on blog.txt:
  -rw-r--r--  root root   (owner=root, group=root, others=read)

After ACL applied:
  -rw-r--r--+ root root   (the + indicates ACL entries exist)

ACL entries:
  user::rw-          (owner root — read/write)
  group::r--         (owning group root — read)
  group:tony:r--     ← ACL entry added by playbook
  mask::r--
  other::r--
```

The `+` in `ls -la` output confirms ACL entries are present.

---

## Run the Playbook

```bash
cd /home/thor/ansible
ansible-playbook -i inventory playbook.yml
```

---

## Expected Output

```
PLAY [Create blog.txt on App Server 1 and set ACL] ****************************

TASK [Gathering Facts] *********************************************************
ok: [stapp01]

TASK [Ensure /opt/security directory exists on stapp01] ************************
changed: [stapp01]

TASK [Create empty file blog.txt on stapp01] ***********************************
changed: [stapp01]

TASK [Set ACL - read permission for group tony on blog.txt] ********************
changed: [stapp01]

PLAY [Create story.txt on App Server 2 and set ACL] ***************************

TASK [Gathering Facts] *********************************************************
ok: [stapp02]

TASK [Ensure /opt/security directory exists on stapp02] ************************
changed: [stapp02]

TASK [Create empty file story.txt on stapp02] **********************************
changed: [stapp02]

TASK [Set ACL - read+write permission for user steve on story.txt] *************
changed: [stapp02]

PLAY [Create media.txt on App Server 3 and set ACL] ***************************

TASK [Gathering Facts] *********************************************************
ok: [stapp03]

TASK [Ensure /opt/security directory exists on stapp03] ************************
changed: [stapp03]

TASK [Create empty file media.txt on stapp03] **********************************
changed: [stapp03]

TASK [Set ACL - read+write permission for group banner on media.txt] ***********
changed: [stapp03]

PLAY RECAP *********************************************************************
stapp01                    : ok=4    changed=3    unreachable=0    failed=0
stapp02                    : ok=4    changed=3    unreachable=0    failed=0
stapp03                    : ok=4    changed=3    unreachable=0    failed=0
```

---

## Verification

```bash
# Check ACL entries on each server
ansible stapp01 -i inventory -m shell -a "getfacl /opt/security/blog.txt"
ansible stapp02 -i inventory -m shell -a "getfacl /opt/security/story.txt"
ansible stapp03 -i inventory -m shell -a "getfacl /opt/security/media.txt"

# Confirm root ownership and the + ACL indicator
ansible stapp01 -i inventory -m shell -a "ls -la /opt/security/blog.txt"
ansible stapp02 -i inventory -m shell -a "ls -la /opt/security/story.txt"
ansible stapp03 -i inventory -m shell -a "ls -la /opt/security/media.txt"
```

**Expected `getfacl` output for stapp01:**
```
# file: opt/security/blog.txt
# owner: root
# group: root
user::rw-
group::r--
group:tony:r--
mask::r--
other::r--
```

---

## Modules Used

| Module  | Purpose |
|---------|---------|
| `file`  | Create `/opt/security/` directory and empty `.txt` files with root ownership |
| `acl`   | Apply fine-grained ACL permissions per user/group on each file |

---

