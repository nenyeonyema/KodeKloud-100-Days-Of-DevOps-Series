# Task 93 — Conditional File Copy to App Servers Using Ansible `when`

## Overview

This task demonstrates Ansible's `when` conditional statement by copying a different file to each app server in Stratos DC based on the server's hostname. A single play targets `all` hosts but each copy task is conditionally gated using `ansible_nodename`, ensuring each file lands only on its intended server.

---

## Requirements

| Server       | Hostname | Source File              | Destination              | Owner  | Group  | Permissions |
|--------------|----------|--------------------------|--------------------------|--------|--------|-------------|
| App Server 1 | stapp01  | `/usr/src/dba/blog.txt`  | `/opt/dba/blog.txt`      | tony   | tony   | `0644`      |
| App Server 2 | stapp02  | `/usr/src/dba/story.txt` | `/opt/dba/story.txt`     | steve  | steve  | `0644`      |
| App Server 3 | stapp03  | `/usr/src/dba/media.txt` | `/opt/dba/media.txt`     | banner | banner | `0644`      |

> Source files reside on the **jump host** at `/usr/src/dba/`. The `copy` module pushes them from the controller to each managed node.

---

## Infrastructure

| Server       | Hostname | IP Address    | SSH User |
|--------------|----------|---------------|----------|
| App Server 1 | stapp01  | 172.16.238.10 | tony     |
| App Server 2 | stapp02  | 172.16.238.11 | steve    |
| App Server 3 | stapp03  | 172.16.238.12 | banner   |

> Sudo password: `Am3ric@`.

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
- name: Conditionally copy files to app servers based on hostname
  hosts: all
  become: yes
  tasks:

    - name: Copy blog.txt to App Server 1 (stapp01)
      copy:
        src: /usr/src/dba/blog.txt
        dest: /opt/dba/blog.txt
        owner: tony
        group: tony
        mode: '0644'
      when: ansible_nodename == "stapp01"

    - name: Copy story.txt to App Server 2 (stapp02)
      copy:
        src: /usr/src/dba/story.txt
        dest: /opt/dba/story.txt
        owner: steve
        group: steve
        mode: '0644'
      when: ansible_nodename == "stapp02"

    - name: Copy media.txt to App Server 3 (stapp03)
      copy:
        src: /usr/src/dba/media.txt
        dest: /opt/dba/media.txt
        owner: banner
        group: banner
        mode: '0644'
      when: ansible_nodename == "stapp03"
```

---

## How It Works — `when` Conditional with `ansible_nodename`

### The `when` keyword

`when` accepts a Jinja2 expression. If the expression evaluates to `true`, the task runs on that host. If `false`, the task is **skipped** — shown as `skipping` in the play output. No error is raised.

```yaml
when: ansible_nodename == "stapp01"
```

This means: *only execute this task if the current host's node name is `stapp01`.*

### Why `ansible_nodename`?

`ansible_nodename` is a **gathered fact** — Ansible collects it from the managed node during the `Gathering Facts` step at the start of each play. It reflects the system's hostname as reported by the OS, which matches the inventory hostnames (`stapp01`, `stapp02`, `stapp03`) in the Stratos DC lab.

| Variable | Source | Value on stapp01 |
|----------|--------|-----------------|
| `ansible_nodename` | Gathered fact (OS hostname) | `stapp01` |
| `inventory_hostname` | Inventory file entry name | `stapp01` |
| `ansible_hostname` | Short hostname from OS | `stapp01` |

In the Stratos DC environment all three resolve to the same value. The task specifically instructs use of `ansible_nodename`.

### Why `hosts: all` with `when` instead of separate plays?

The task explicitly requires `hosts: all`. This is a deliberate Ansible training exercise to show how `when` conditionals filter task execution **within** a broad host target rather than narrowing the host scope. The result is:

- All three servers connect and gather facts
- Each copy task runs against all three servers
- The `when` condition causes two of the three servers to **skip** each task
- Net effect: each file lands on exactly one server

This is different from Task 90 which used three separate plays with `hosts: stapp01`, `hosts: stapp02`, `hosts: stapp03`.

---

## Run the Playbook

```bash
cd /home/thor/ansible
ansible-playbook -i inventory playbook.yml
```

---

## Expected Output

```
PLAY [Conditionally copy files to app servers based on hostname] ****************

TASK [Gathering Facts] *********************************************************
ok: [stapp01]
ok: [stapp02]
ok: [stapp03]

TASK [Copy blog.txt to App Server 1 (stapp01)] *********************************
changed: [stapp01]
skipping: [stapp02]
skipping: [stapp03]

TASK [Copy story.txt to App Server 2 (stapp02)] ********************************
skipping: [stapp01]
changed: [stapp02]
skipping: [stapp03]

TASK [Copy media.txt to App Server 3 (stapp03)] ********************************
skipping: [stapp01]
skipping: [stapp02]
changed: [stapp03]

PLAY RECAP *********************************************************************
stapp01                    : ok=2    changed=1    unreachable=0    failed=0    skipped=2
stapp02                    : ok=2    changed=1    unreachable=0    failed=0    skipped=2
stapp03                    : ok=2    changed=1    unreachable=0    failed=0    skipped=2
```

The `skipped=2` count per host confirms that two tasks were conditionally bypassed on each server — exactly as intended.

---

## Verification

```bash
# Confirm each file landed on the correct server with correct metadata
ansible stapp01 -i inventory -m shell -a "ls -la /opt/dba/blog.txt"
ansible stapp02 -i inventory -m shell -a "ls -la /opt/dba/story.txt"
ansible stapp03 -i inventory -m shell -a "ls -la /opt/dba/media.txt"

# Confirm files were NOT copied to the wrong servers
ansible stapp01 -i inventory -m shell -a "ls /opt/dba/"
ansible stapp02 -i inventory -m shell -a "ls /opt/dba/"
ansible stapp03 -i inventory -m shell -a "ls /opt/dba/"
```

**Expected `ls -la` output on stapp01:**
```
-rw-r--r-- 1 tony tony <size> <date> /opt/dba/blog.txt
```

---

## Comparison of Approaches — `when` vs Separate Plays vs Per-Host Inventory Groups

| Approach | How targeting works | Used in task |
|----------|-------------------|--------------|
| `when` conditional (`hosts: all`) | All hosts connect; tasks skip based on fact value | Task 93 ✅ |
| Separate plays per host (`hosts: stapp01`) | Only one host connects per play | Task 90 |
| Per-host inventory groups | Inventory structure controls which hosts run which plays | — |

All three produce the same end result. `when` conditionals are the most flexible — they can evaluate any gathered fact, registered variable, or custom variable, not just hostnames.

---

## Modules Used

| Module | Purpose |
|--------|---------|
| `copy` | Push files from the Ansible controller (jump host) to managed nodes |

---

